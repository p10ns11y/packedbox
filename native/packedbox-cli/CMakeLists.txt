cmake_minimum_required(VERSION 3.16)
project(packedbox-cli C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Phase 3: FetchContent elomaxz from https://github.com/p10ns11y/elomaxz
# include(FetchContent)
# FetchContent_Declare(elomaxz GIT_REPOSITORY https://github.com/p10ns11y/elomaxz.git ...)
# FetchContent_MakeAvailable(elomaxz)

add_executable(packedbox src/main.c)
target_include_directories(packedbox PRIVATE include)

install(TARGETS packedbox DESTINATION bin)
