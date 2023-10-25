FROM rust:buster as builder-gifski
RUN cargo install --version 1.7.0 gifski

FROM gcc:13 as builder-lottie-to-png
RUN apt update && \
    apt install --assume-yes cmake python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 install --break-system-packages conan==2.0.10

WORKDIR /application
RUN conan profile detect
COPY conanfile.txt .
RUN conan install . --build=missing -s build_type=Release

COPY CMakeLists.txt .
COPY src src
RUN cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && cmake --build . --config Release

FROM debian:buster-slim as lottie-to-gif
COPY --from=builder-gifski /usr/local/cargo/bin/gifski /usr/bin/gifski
COPY --from=builder-lottie-to-png /application/bin/lottie_to_png /usr/bin/lottie_to_png
COPY bin/lottie_common.sh /usr/bin
COPY bin/lottie_to_gif.sh /usr/bin
CMD bash -c "\
    find /source -type f \( -iname \*.json -o -iname \*.lottie -o -iname \*.tgs \) | while IFS=$'\n' read -r FILE; do \
        echo Converting \${FILE}... && lottie_to_\${FORMAT}.sh \${WIDTH:+--width \$WIDTH} \${HEIGHT:+--height \$HEIGHT} \${FPS:+--fps \$FPS} \${QUALITY:+--quality \$QUALITY} \$FILE && echo Done.; \
    done\
"
ENV FORMAT=gif

FROM alpine:3.16.2 as builder-lottie-to-some
COPY --from=builder-lottie-to-png /application/bin/lottie_to_png /usr/bin/lottie_to_png
COPY bin/* /usr/bin/
CMD sh -c "\
    find /source -type f \( -iname \*.json -o -iname \*.lottie -o -iname \*.tgs \) | while IFS=$'\n' read -r FILE; do \
        echo Converting \${FILE}... && lottie_to_\${FORMAT}.sh \${WIDTH:+--width \$WIDTH} \${HEIGHT:+--height \$HEIGHT} \${FPS:+--fps \$FPS} \${QUALITY:+--quality \$QUALITY} \$FILE && echo Done.; \
    done\
"

FROM builder-lottie-to-some as lottie-to-apng
RUN apk --no-cache add ffmpeg
ENV FORMAT=apng

FROM builder-lottie-to-some as lottie-to-png
ENV FORMAT=png

FROM builder-lottie-to-some as lottie-to-webp
RUN apk --no-cache add libwebp-tools
ENV FORMAT=webp
