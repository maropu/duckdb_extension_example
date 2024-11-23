cmake_minimum_required(VERSION 2.8.12)
set(TARGET_NAME sayhello)
project(${TARGET_NAME})

set(OVERRIDE_GIT_DESCRIBE "v1.1.1")

if(NOT MSVC)
  set(SAYHELLO_EXTRA_CFLAGS
      "-Wno-pedantic -Wno-sign-compare -Wno-unused-variable")
endif()

set(CMAKE_CXX_FLAGS_DEBUG
    "${CMAKE_CXX_FLAGS_DEBUG} ${SAYHELLO_EXTRA_CFLAGS}")
set(CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} ${SAYHELLO_EXTRA_CFLAGS}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO
    "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} ${SAYHELLO_EXTRA_CFLAGS}")

set(CMAKE_C_FLAGS_DEBUG
    "${CMAKE_C_FLAGS_DEBUG} ${SAYHELLO_EXTRA_CFLAGS} ${SAYHELLO_EXTRA_CFLAGS}"
)
set(CMAKE_C_FLAGS_RELEASE
    "${CMAKE_C_FLAGS_RELEASE} ${SAYHELLO_EXTRA_CFLAGS}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO
    "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${SAYHELLO_EXTRA_CFLAGS}")

add_subdirectory(src)


set(PARAMETERS "-no-warnings")
build_loadable_extension(${TARGET_NAME} ${PARAMETERS} ${ALL_OBJECT_FILES})

# if(WIN32)
#   target_include_directories(
#     ${TARGET_NAME}_loadable_extension)
# endif()
#
# set_property(TARGET ${TARGET_NAME}_loadable_extension PROPERTY C_STANDARD 99)
#
# if(WIN32)
#   target_link_libraries(${TARGET_NAME}_loadable_extension wsock32 ws2_32
#                         wldap32 secur32 crypt32)
# endif()
