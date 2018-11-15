##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

#.rst:
# FindGridTools
# ----------------
#
# .. code-block:: cmake
#
#   find_package(GridTools [REQUIRED] [QUIET])
#
# Find the GridTools include paths.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# Defines the following variables:
#
# ``GridTools_FOUND``                    
#   True if GridTools was found.
# ``GRIDTOOLS_INCLUDE_DIRS``
#   Where to find GridTools includes.
#
if( NOT GRIDTOOLS_FOUND )

  find_path( GRIDTOOLS_INCLUDE_DIR 
             NAMES stencil-composition.hpp
             PATHS 
                ${CMAKE_INSTALL_PREFIX}
                "${GRIDTOOLS_PATH}"
                "${GRIDTOOLS_ROOT}"
                ENV GRIDTOOLS_PATH 
            PATH_SUFFIXES include/gridtools/stencil-composition/
  )

  include(FindPackageHandleStandardArgs)

  # handle the QUIETLY and REQUIRED arguments and set GRIDTOOLS_FOUND to TRUE
  find_package_handle_standard_args( gridtools DEFAULT_MSG
                                     GRIDTOOLS_INCLUDE_DIR )

  mark_as_advanced( GRIDTOOLS_INCLUDE_DIRS GRIDTOOLS_LIBRARIES )

  set( GridTools_FOUND ${GRIDTOOLS_FOUND} )
  set( GRIDTOOLS_INCLUDE_DIRS ${GRIDTOOLS_INCLUDE_DIR}/../..)
endif()

