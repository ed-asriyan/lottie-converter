FROM alpine
MAINTAINER Ed Asriyan <ed-asriyan@protonmail.com>

RUN apk update && \
    apk --no-cache add \
        build-base \
        git \
        gcc \
        g++ \
        cmake \
        libstdc++ \
        py-pip && \
        pip install --ignore-installed conan;

RUN git clone https://github.com/Samsung/rlottie.git && (cd rlottie && cmake CMakeLists.txt && make && make install) && rm -fr rlottie

WORKDIR /application
ADD conanfile.txt .
RUN conan install .

ADD CMakeLists.txt .
ADD zstr ./zstr
ADD gif ./gif
ADD main.cpp .

RUN cmake CMakeLists.txt && make && mv bin/tgs_to_gif /usr/bin/tgs_to_gif

ENV WIDTH=512
ENV HEIGHT=512
ENV FPS=0

CMD tgs_to_gif --width $WIDTH --height $HEIGHT --fps $FPS /source  
