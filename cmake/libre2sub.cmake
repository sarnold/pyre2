if("${RE2_PATH}" STREQUAL "")
  message(STATUS "Using default submodule path")
  set(RE2_PATH ${PROJECT_SOURCE_DIR}/libre2)
endif()

set(RE2_SOURCES
    ${RE2_PATH}/re2/bitstate.cc
    ${RE2_PATH}/re2/compile.cc
    ${RE2_PATH}/re2/dfa.cc
    ${RE2_PATH}/re2/filtered_re2.cc
    ${RE2_PATH}/re2/mimics_pcre.cc
    ${RE2_PATH}/re2/nfa.cc
    ${RE2_PATH}/re2/onepass.cc
    ${RE2_PATH}/re2/parse.cc
    ${RE2_PATH}/re2/perl_groups.cc
    ${RE2_PATH}/re2/prefilter.cc
    ${RE2_PATH}/re2/prefilter_tree.cc
    ${RE2_PATH}/re2/prog.cc
    ${RE2_PATH}/re2/re2.cc
    ${RE2_PATH}/re2/regexp.cc
    ${RE2_PATH}/re2/set.cc
    ${RE2_PATH}/re2/simplify.cc
    ${RE2_PATH}/re2/stringpiece.cc
    ${RE2_PATH}/re2/tostring.cc
    ${RE2_PATH}/re2/unicode_casefold.cc
    ${RE2_PATH}/re2/unicode_groups.cc
    ${RE2_PATH}/util/rune.cc
    ${RE2_PATH}/util/strutil.cc
)

if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  if(MSVC_VERSION LESS 1900)
    message(FATAL_ERROR "you need Visual Studio 2015 or later")
  endif()
  # See http://www.kitware.com/blog/home/post/939 for details.
  #set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
  # CMake defaults to /W3, but some users like /W4 (or /Wall) and /WX,
  # so we disable various warnings that aren't particularly helpful.
  add_compile_options(/wd4100 /wd4201 /wd4456 /wd4457 /wd4702 /wd4815)
  # Without a byte order mark (BOM), Visual Studio assumes that the source
  # file is encoded using the current user code page, so we specify UTF-8.
  add_compile_options(/utf-8)
endif()

if(WIN32)
  add_definitions(-DUNICODE -D_UNICODE -DSTRICT -DNOMINMAX)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS)
elseif(UNIX)
  set(THREADS_PREFER_PTHREAD_FLAG ON)
endif()
