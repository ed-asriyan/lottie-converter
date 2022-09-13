FROM rust:alpine as builder-gifski
# https://stackoverflow.com/a/30873179
RUN apk add --no-cache musl-dev
RUN cargo install --version 1.7.0 gifski

FROM alpine as builder-tgs-to-png
RUN apk update && \
    apk --no-cache add \
        build-base \
        git \
        gcc \
        g++ \
        cmake \
        libstdc++ \
        py-pip && \
        pip install --ignore-installed conan
WORKDIR /application
ADD conanfile.txt .
RUN conan install .
ADD CMakeLists.txt .
ADD src src
RUN cmake CMakeLists.txt && make

FROM alpine as builder-tgs-to-some
COPY --from=builder-tgs-to-png /application/bin/tgs_to_png /usr/bin/tgs_to_png
ADD bin/* /usr/bin/
CMD sh -c "\
    find /source -name '*.tgs' | while IFS=$'\n' read -r FILE; do \
        echo Converting \${FILE}... && tgs_to_\${FORMAT}.sh \${WIDTH:+--width \$WIDTH} \${HEIGHT:+--height \$HEIGHT} \${FPS:+--fps \$FPS} \${QUALITY:+--quality \$QUALITY} \$FILE && echo Done.; \
    done\
"

FROM builder-tgs-to-some as tgs-to-apng
RUN apk --no-cache add ffmpeg
ENV FORMAT=apng

FROM builder-tgs-to-some as tgs-to-gif
COPY --from=builder-gifski /usr/local/cargo/bin/gifski /usr/bin/gifski
ENV FORMAT=gif

FROM builder-tgs-to-some as tgs-to-png
ENV FORMAT=png

FROM builder-tgs-to-some as tgs-to-webp
RUN apk --no-cache add libwebp-tools
ENV FORMAT=webp
