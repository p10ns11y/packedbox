cmake_minimum_required(VERSION 3.16)
project(packedbox-ui C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

option(PACKEDBOX_UI_BUILD_GTK "Build GTK4/libadwaita UI when dependencies are found" ON)

set(PACKEDBOX_UI_COMMON_SOURCES
    src/main.c
    src/ui_entry.c
    src/paths.c
    src/jobs.c
)

set(PACKEDBOX_UI_HAVE_GTK FALSE)

if(PACKEDBOX_UI_BUILD_GTK)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_check_modules(GTK4 QUIET gtk4)
        pkg_check_modules(ADW QUIET libadwaita-1)
    endif()
    if(GTK4_FOUND AND ADW_FOUND)
        set(PACKEDBOX_UI_HAVE_GTK TRUE)
    endif()
endif()

if(PACKEDBOX_UI_HAVE_GTK)
    message(STATUS "packedbox-ui: building GTK4/libadwaita application")
    add_executable(packedbox-ui
        ${PACKEDBOX_UI_COMMON_SOURCES}
        src/ui_app.c
        src/ui_runner.c
    )
    target_compile_definitions(packedbox-ui PRIVATE PACKEDBOX_UI_HAVE_GTK=1)
    target_include_directories(packedbox-ui PRIVATE include)
    target_include_directories(packedbox-ui SYSTEM PRIVATE ${GTK4_INCLUDE_DIRS} ${ADW_INCLUDE_DIRS})
    target_link_libraries(packedbox-ui PRIVATE ${GTK4_LIBRARIES} ${ADW_LIBRARIES})
    target_compile_options(packedbox-ui PRIVATE ${GTK4_CFLAGS_OTHER} ${ADW_CFLAGS_OTHER})
else()
    message(STATUS "packedbox-ui: GTK4/libadwaita not found — building headless stub")
    message(STATUS "  Install dev packages, e.g. libgtk-4-dev libadwaita-1-dev (Debian/Ubuntu)")
    add_executable(packedbox-ui
        ${PACKEDBOX_UI_COMMON_SOURCES}
    )
    target_include_directories(packedbox-ui PRIVATE include)
endif()

target_compile_options(packedbox-ui PRIVATE
    -Wall
    -Wextra
    -Werror
    -Wconversion
    -Wshadow
)

install(TARGETS packedbox-ui DESTINATION bin)

enable_testing()
add_test(NAME packedbox_ui_version COMMAND packedbox-ui --version)
add_test(NAME packedbox_ui_help COMMAND packedbox-ui --help)

if(NOT PACKEDBOX_UI_HAVE_GTK)
    add_test(NAME packedbox_ui_stub_banner COMMAND packedbox-ui)
endif()
