cmake_minimum_required(VERSION 3.18)

if(POLICY CMP0077)
    cmake_policy(SET CMP0077 NEW) # option() honors variables already set
endif()

option(PY_DEBUG "Set if python being linked is a Py_DEBUG build" OFF)
option(USE_GIT_SUBMODULE "Use submodules during build" ON)
option(USE_LIBRE2_PKG "Use OS-provided libdatrie package" OFF)

if(DEFINED ENV{HAVE_LIBRE2_PKG})
  set(USE_LIBRE2_PKG "$ENV{HAVE_LIBRE2_PKG}")
endif()

if(USE_LIBRE2_PKG)
  set(USE_GIT_SUBMODULE OFF)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  set(CLANG_DEFAULT_CXX_STDLIB libc++)
  set(CLANG_DEFAULT_RTLIB compiler-rt)
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING
            "Default build type: RelWithDebInfo" FORCE)
endif()

if(NOT SCM_VERSION_INFO)
        # use git describe for scm_version
        EXECUTE_PROCESS(COMMAND git describe --tags
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        OUTPUT_VARIABLE SCM_VERSION_INFO
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

project(re2 LANGUAGES C CXX VERSION ${SCM_VERSION_INFO})

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE ON)  # this does nothing with ninja :/
#set(CMAKE_VERBOSE_BUILD ON)  # this also does nothing with ninja :/

message(STATUS "Trying ${CMAKE_BUILD_TYPE} build type for pyre2 ${SCM_VERSION_INFO}")

include(GNUInstallDirs)
include(CheckIncludeFile)
include(CheckIncludeFileCXX)
include(CheckIncludeFiles)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

if(USE_LIBRE2_PKG)
  message(STATUS "Trying system re2")
  find_package(re2 CONFIG NAMES re2)
endif()

if(USE_LIBRE2_PKG AND NOT re2_FOUND)
  message(STATUS "Trying PkgConfig")
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(RE2 IMPORTED_TARGET re2)
endif()

if(USE_GIT_SUBMODULE)
  message(STATUS "Trying libre2 submodule")
  find_package(Git)
  if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    message(STATUS "Checking submodule state")
    # Update submodules as needed
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/libre2/re2.pc.in")
      message(STATUS "Submodule update")
      execute_process(
        COMMAND ${GIT_EXECUTABLE} submodule update --init
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE GIT_SUBMOD_RESULT
      )
      if(NOT GIT_SUBMOD_RESULT EQUAL "0")
        message(
          FATAL_ERROR
            "git submodule update --init failed with ${GIT_SUBMOD_RESULT}, please checkout submodules"
          )
      endif()
    endif()
  endif()
  include(${CMAKE_SOURCE_DIR}/cmake/libre2sub.cmake)
endif()

set(PYBIND11_FINDPYTHON ON)
find_package(pybind11)

if(pybind11_FOUND)
  message(STATUS "System pybind11 found")
else()
  message(STATUS "Fetching pybind11 from github")
  # Fetch pybind11
  include(FetchContent)

  FetchContent_Declare(
    pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11
    GIT_TAG v2.11.1
  )
  FetchContent_MakeAvailable(pybind11)
endif()

find_package(Threads REQUIRED)

if (${PYTHON_IS_DEBUG})
  set(PY_DEBUG ON)
endif()

include_directories(${PROJECT_SOURCE_DIR}/src)
add_subdirectory(src)
