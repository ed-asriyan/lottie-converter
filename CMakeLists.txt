cmake_minimum_required(VERSION 3.5)
project(tgs_to_gif)

set(CMAKE_CXX_STANDARD 17)

include(conanbuildinfo.cmake)
conan_basic_setup()

add_executable(
        tgs_to_gif
        main.cpp
        gif/gif_builder.cpp gif/gif_builder.h
        gif/gif.cpp gif/gif.h
        gif/render.cpp gif/render.h
        zstr/fstream.h zstr/zstr.h
)
target_link_libraries(tgs_to_gif ${CONAN_LIBS} rlottie)
