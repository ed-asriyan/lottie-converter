FROM rust:alpine as builder-gifski
# https://stackoverflow.com/a/30873179
RUN apk add --no-cache musl-dev
RUN cargo install --version 1.7.0 gifski

FROM alpine:3.16.2 as builder-lottie-to-png
RUN apk update && \
    apk --no-cache add \
        build-base \
        git \
        gcc \
        g++ \
        cmake \
        libstdc++ \
        py-pip && \
        pip install --ignore-installed conan==1.53.0
WORKDIR /application
ADD conanfile.txt .
RUN conan install .
ADD CMakeLists.txt .
ADD src src
RUN cmake CMakeLists.txt && make

FROM alpine:3.16.2 as builder-lottie-to-some
COPY --from=builder-lottie-to-png /application/bin/lottie_to_png /usr/bin/lottie_to_png
ADD bin/* /usr/bin/
CMD sh -c "\
    find /source -type f \( -iname \*.json -o -iname \*.lottie -o -iname \*.tgs \) | while IFS=$'\n' read -r FILE; do \
        echo Converting \${FILE}... && lottie_to_\${FORMAT}.sh \${WIDTH:+--width \$WIDTH} \${HEIGHT:+--height \$HEIGHT} \${FPS:+--fps \$FPS} \${QUALITY:+--quality \$QUALITY} \$FILE && echo Done.; \
    done\
"

FROM builder-lottie-to-some as lottie-to-apng
RUN apk --no-cache add ffmpeg
ENV FORMAT=apng

FROM builder-lottie-to-some as lottie-to-gif
COPY --from=builder-gifski /usr/local/cargo/bin/gifski /usr/bin/gifski
ENV FORMAT=gif

FROM builder-lottie-to-some as lottie-to-png
ENV FORMAT=png

FROM builder-lottie-to-some as lottie-to-webp
RUN apk --no-cache add libwebp-tools
ENV FORMAT=webp
