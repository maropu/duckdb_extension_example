include_directories(include)

add_library(
  sayhello_ext_library OBJECT
  sayhello.cpp
  sayhello_extension.cpp)
set(ALL_OBJECT_FILES
    ${ALL_OBJECT_FILES} $<TARGET_OBJECTS:sayhello_ext_library>
    PARENT_SCOPE)
