cmake_minimum_required(VERSION 3.16)
project(packedbox-cli C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

include(FetchContent)

set(PACKEDBOX_ELOMAXZ_GIT_TAG "v0.1" CACHE STRING "elomaxz git tag or commit")

if(DEFINED ENV{PACKEDBOX_ELOMAXZ_SOURCE_DIR} AND EXISTS "$ENV{PACKEDBOX_ELOMAXZ_SOURCE_DIR}/src/elomaxz.c")
    set(elomaxz_SOURCE_DIR "$ENV{PACKEDBOX_ELOMAXZ_SOURCE_DIR}")
    message(STATUS "Using local elomaxz at ${elomaxz_SOURCE_DIR}")
else()
    FetchContent_Declare(
        elomaxz
        GIT_REPOSITORY https://github.com/p10ns11y/elomaxz.git
        GIT_TAG ${PACKEDBOX_ELOMAXZ_GIT_TAG}
        GIT_SHALLOW TRUE
    )
    FetchContent_GetProperties(elomaxz)
    if(NOT elomaxz_POPULATED)
        FetchContent_Populate(elomaxz)
    endif()
endif()

add_library(elomaxz STATIC "${elomaxz_SOURCE_DIR}/src/elomaxz.c")
target_include_directories(elomaxz PUBLIC "${elomaxz_SOURCE_DIR}/include")

add_executable(packedbox
    src/main.c
    src/cli.c
    src/app.c
)
target_include_directories(packedbox PRIVATE include)
target_link_libraries(packedbox PRIVATE elomaxz)
target_compile_options(packedbox PRIVATE
    -Wall
    -Wextra
    -Werror
    -Wconversion
    -Wshadow
)

install(TARGETS packedbox DESTINATION bin)

enable_testing()
add_test(NAME packedbox_version COMMAND packedbox --version)
add_test(NAME packedbox_help COMMAND packedbox --help)
add_test(NAME packedbox_status COMMAND packedbox status)
add_test(NAME packedbox_audit COMMAND packedbox audit)
