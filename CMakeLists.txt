cmake_minimum_required(VERSION 3.5)
project(lottie_to_png)

set(CMAKE_CXX_STANDARD 17)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    # https://stackoverflow.com/a/3801032
    set(STATIC_LINKING_DEFAULT_VALUE OFF)
else()
    set(STATIC_LINKING_DEFAULT_VALUE ON)
endif()

option(LOTTIE_TO_PNG_STATIC_LINKING "Build using static linking" ${STATIC_LINKING_DEFAULT_VALUE})

if (LOTTIE_TO_PNG_STATIC_LINKING)
    # enable static linking https://stackoverflow.com/a/24671474
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
    set(BUILD_SHARED_LIBS OFF)
    set(CMAKE_EXE_LINKER_FLAGS "-static")
endif()

#
# conan dependencies
#
find_package(PNG REQUIRED)
find_package(ZLIB REQUIRED)

#
# cmake dependencies
#
include(FetchContent)

FetchContent_Declare(
    rlottie
    GIT_REPOSITORY https://github.com/Samsung/rlottie.git
    GIT_TAG "875626965959d8e269ca22175c8e1ad190696c43"
)
FetchContent_MakeAvailable(rlottie)

FetchContent_Declare(
    argparse
    GIT_REPOSITORY https://github.com/p-ranav/argparse.git
    GIT_TAG "v2.6"

)
FetchContent_MakeAvailable(argparse)

#
# target executable
#
add_executable(
    ${PROJECT_NAME}
    src/main.cpp
    src/render.cpp src/render.h
)
target_compile_options(${PROJECT_NAME} PUBLIC)
target_link_libraries(
    ${PROJECT_NAME}
    argparse
    rlottie
    PNG::PNG
    ZLIB::ZLIB
    pthread
)
set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "bin")
