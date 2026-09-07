cmake_minimum_required(VERSION 3.16)
project(packedbox-ui C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Phase 4: find GTK4 and libadwaita
# find_package(PkgConfig REQUIRED)
# pkg_check_modules(GTK4 REQUIRED gtk4)
# pkg_check_modules(ADW REQUIRED libadwaita-1)

add_executable(packedbox-ui src/main.c)
# target_link_libraries(packedbox-ui ${GTK4_LIBRARIES} ${ADW_LIBRARIES})

install(TARGETS packedbox-ui DESTINATION bin)
