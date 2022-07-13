cmake_minimum_required(VERSION 3.5)
project(tgs_to_png)
include(ExternalProject)

set(CMAKE_CXX_STANDARD 17)

include(conanbuildinfo.cmake)
conan_basic_setup()

# enable static linking https://stackoverflow.com/a/24671474
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
set(BUILD_SHARED_LIBS OFF)
set(CMAKE_EXE_LINKER_FLAGS "-static")

add_executable(
        ${PROJECT_NAME}
        src/main.cpp
        src/render.cpp src/render.h
        src/zstr/fstream.h src/zstr/zstr.h
)

ExternalProject_Add(
        rlottie
        GIT_REPOSITORY "https://github.com/Samsung/rlottie.git"
        GIT_TAG "875626965959d8e269ca22175c8e1ad190696c43"
        ${ARGN}
        PREFIX "${CMAKE_BINARY_DIR}/lib"
        CMAKE_ARGS
        -Wno-dev
        "-DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}"
        "-DCMAKE_USER_MAKE_RULES_OVERRIDE=${CMAKE_USER_MAKE_RULES_OVERRIDE}"
        "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}"
        "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}"
        "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
        "-DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>"
        "-DLOTTIE_MODULE=OFF"
        "-DBUILD_SHARED_LIBS=OFF"
        "-DLIB_INSTALL_DIR=${CMAKE_BINARY_DIR}/lib/rlottie"
        BUILD_BYPRODUCTS "${CMAKE_BINARY_DIR}/lib/rlottie/librlottie.a"
)
set(INCLUDES ${INCLUDES} "${CMAKE_BINARY_DIR}/lib/src/rlottie/inc")
set(LIBS ${LIBS} pthread "${CMAKE_BINARY_DIR}/lib/src/rlottie-build/librlottie.a")
add_dependencies(${PROJECT_NAME} rlottie)

include_directories(${INCLUDES})
target_link_libraries(${PROJECT_NAME} -static ${CONAN_LIBS} ${LIBS})
target_compile_options(${PROJECT_NAME} PUBLIC)
