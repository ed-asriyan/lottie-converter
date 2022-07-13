FROM rust:alpine as builder-gifski
MAINTAINER Ed Asriyan <tgs-to-gif.dockerfile@asriyan.me>

# https://stackoverflow.com/a/30873179
RUN apk add --no-cache musl-dev
RUN cargo install --version 1.7.0 gifski

FROM alpine as builder-tgs-to-png
MAINTAINER Ed Asriyan <tgs-to-gif.dockerfile@asriyan.me>

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

FROM alpine
WORKDIR /application

RUN apk --no-cache add libwebp-tools

COPY --from=builder-gifski /usr/local/cargo/bin/gifski /usr/local/bin/gifski
COPY --from=builder-tgs-to-png /application/bin/tgs_to_png /application/bin/tgs_to_png

ADD tgs_to_png.sh .
ADD tgs_to_webp.sh .
ADD tgs_to_gif.sh .

ENV WIDTH=512
ENV HEIGHT=512
ENV FPS=50
ENV QUALITY=90

CMD sh -c "\
    find /source -name '*.tgs' | while IFS=$'\n' read -r FILE; do \
        echo Converting \${FILE}... && /application/tgs_to_gif.sh --width \$WIDTH --height \$HEIGHT --fps \$FPS --quality \$QUALITY \$FILE && echo Done.; \
    done\
"
