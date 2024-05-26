cmake_minimum_required(VERSION 3.5)
project(lottie_to_png)

set(CMAKE_CXX_STANDARD 17)

# building and linking the project's internal libraries dynamically
set(BUILD_SHARED_LIBS OFF)

# search for static versions of external libraries
IF(WIN32)
    SET(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
ELSE(WIN32)
    SET(CMAKE_FIND_LIBRARY_SUFFIXES .a)
ENDIF(WIN32)

# enable static linking of system libraries
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
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
    GIT_REPOSITORY https://github.com/gilzoide/rlottie.git
    GIT_TAG "24a99042591293a23ee26ead0f2130bc88f08139"
)
FetchContent_MakeAvailable(rlottie)

FetchContent_Declare(
    argparse
    GIT_REPOSITORY https://github.com/p-ranav/argparse.git
    GIT_TAG "v2.6"

)
FetchContent_MakeAvailable(argparse)

#
# rest of packages required
#
find_package(Threads REQUIRED)
if (CMAKE_VERSION VERSION_LESS 3.1.0)
    set(Threads ${CMAKE_THREAD_LIBS_INIT})
else()
    set(Threads Threads::Threads)
endif()

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
    ${Threads}
)
set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "bin")
