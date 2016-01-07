cmake_minimum_required(VERSION 2.8)
project(opengl-renderer )

#--- where to find Find*.cmake
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

#--- FIND OPENGL
find_package(GLFW REQUIRED)
include_directories(${GLFW_INCLUDE_DIRS})
add_definitions(${GLFW_DEFINITIONS})
if(NOT GLFW_FOUND)
    message(ERROR " GLFW not found!")
endif()

#--- FIND OPENGL
find_package(OpenGL REQUIRED)
include_directories(${OpenGL_INCLUDE_DIRS})
link_directories(${OpenGL_LIBRARY_DIRS})
add_definitions(${OpenGL_DEFINITIONS})
if(NOT OPENGL_FOUND) 
    message(ERROR " OPENGL not found!")
endif()

#--- GLEW (STATICALLY LINKED)
find_package(GLEW REQUIRED)
include_directories(${GLEW_INCLUDE_DIRS})
link_directories(${GLEW_LIBRARY_DIRS})
add_definitions(-DGLEW_STATIC)

#--- EIGEN
find_package(Eigen3 REQUIRED)
include_directories(${EIGEN3_INCLUDE_DIRS})

#--- OPENGP
find_package(OpenGP REQUIRED)
include_directories(${OpenGP_INCLUDE_DIRS})
add_definitions(-DHEADERONLY)
add_definitions(-DUSE_EIGEN)
if(NOT OPENGP_FOUND)
    message(ERROR " OPENGP not found!")
endif()

include(ConfigureQt.cmake)

#--- Common headers/libraries for all the exercises
include_directories(${CMAKE_CURRENT_LIST_DIR})
SET(COMMON_LIBS ${OPENGL_LIBRARIES} ${GLFW_LIBRARIES} ${GLEW_LIBRARIES})

##--- Deploy / link rules
execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/data_points_fshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/data_points_vshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/lines_fshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/lines_vshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/model_fshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/model_vshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/model_points_fshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
execute_process(COMMAND ln -f -s ${CMAKE_SOURCE_DIR}/model_points_vshader.glsl WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
 
add_executable(opengl-renderer opengl-renderer.cpp data_points_fshader.glsl data_points_vshader.glsl lines_fshader.glsl lines_vshader.glsl model_fshader.glsl model_vshader.glsl model_points_fshader.glsl model_points_vshader.glsl)
target_link_libraries(opengl-renderer ${COMMON_LIBS})
