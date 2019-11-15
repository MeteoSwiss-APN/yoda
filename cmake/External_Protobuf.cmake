##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT).
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(ExternalProject)
include(yodaSetExternalProperties)
include (yodaRequireArg)

set(DIR_OF_PROTO_EXTERNAL ${CMAKE_CURRENT_LIST_DIR})

function(yoda_external_package)
  set(options)
  set(one_value_args URL URL_MD5 DOWNLOAD_DIR)
  set(multi_value_args REQUIRED_VARS CMAKE_ARGS)
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  yoda_require_arg("URL" ${ARG_URL})
  yoda_require_arg("DOWNLOAD_DIR" ${ARG_DOWNLOAD_DIR})
  yoda_require_arg("URL_MD5" ${ARG_URL_MD5})

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  set(cmake_args
    ${ARG_CMAKE_ARGS}
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -fPIC"
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DBUILD_SHARED_LIBS=OFF
    -Dprotobuf_BUILD_EXAMPLES=OFF
    -Dprotobuf_BUILD_SHARED_LIBS=OFF
    -Dprotobuf_BUILD_TESTS=OFF
    -Dprotobuf_INSTALL_EXAMPLES=OFF
  )

  yoda_set_external_properties(NAME "protobuf"
    INSTALL_DIR install_dir
    SOURCE_DIR source_dir)

  # Python protobuf
  if(NOT DEFINED PYTHON_EXECUTABLE)
    find_package(PythonInterp 3.4 REQUIRED)
  endif()
  find_package(bash REQUIRED)

  set(PROTOBUF_PROTOC "${CMAKE_BINARY_DIR}/protobuf-prefix/src/protobuf-build/protoc" CACHE INTERNAL "")
  set(PROTOBUF_LIBPROTOBUF_PATH "${install_dir}/lib" CACHE INTERNAL "")
  set(PROTOBUF_PYTHON_SOURCE "${source_dir}/python" CACHE INTERNAL "")
  set(PROTOBUF_PYTHON_INSTALL "${install_dir}/python" CACHE INTERNAL "" )
  set(PROTOBUF_CMAKE_EXECUTABLE "${CMAKE_COMMAND}" CACHE INTERNAL "")
  set(PROTOBUF_PYTHON_EXECUTABLE "${PYTHON_EXECUTABLE}" CACHE INTERNAL "")

  set(install_script_in "${DIR_OF_PROTO_EXTERNAL}/templates/protobuf_python_install_script.sh.in")
  set(install_script "${CMAKE_CURRENT_BINARY_DIR}/protobuf_python_install_script.sh")
  configure_file(${install_script_in} ${install_script} @ONLY)


  set(_PROTOBUF_INSTALL_DIR_ ${install_dir})
  set(_PROTOBUF_SOURCE_DIR_ ${CMAKE_BINARY_DIR}/protobuf-prefix/src/protobuf)
  include(yodaGetScriptDir)
  yoda_get_script_dir(script_dir)

  set(post_build_input_script ${script_dir}/protobuf-postbuild.cmake.in)
  set(post_build_output_script ${CMAKE_BINARY_DIR}/yoda-cmake/cmake/protobuf-postbuild.cmake)

  # Configure the script
  configure_file(${post_build_input_script} ${post_build_output_script} @ONLY)


  # C++ protobuf
  ExternalProject_Add(protobuf
    DOWNLOAD_DIR ${ARG_DOWNLOAD_DIR}
    URL ${ARG_URL}
    URL_MD5 ${ARG_URL_MD5}
    SOURCE_DIR "${source_dir}"
    INSTALL_DIR "${install_dir}"
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} <SOURCE_DIR>/cmake ${cmake_args}
    STEP_TARGETS python-build post-build
  )
  ExternalProject_Add_Step(
    protobuf python-build
    COMMAND ${BASH_EXECUTABLE} ${install_script}
    DEPENDEES build install
  )
  ExternalProject_Add_Step(
    protobuf post-build
    COMMAND ${CMAKE_COMMAND} -P ${post_build_output_script}
    DEPENDEES install python-build
  )

  ExternalProject_Get_Property(protobuf install_dir)
  set(Protobuf_DIR "${install_dir}/lib/cmake/protobuf" CACHE INTERNAL "")

endfunction()
