##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(yodaIncludeGuard)
yoda_include_guard()

include(yodaCheckInSourceBuild)
include(yodaGetArchitectureInfo)
include(yodaGetCompilerInfo)
include(yodaGetPlatformInfo)
include(yodaMakeStringPair)
include(yodaReportResult)

#we add the modules directory of yoda
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/modules")

#.rst:
# yoda_init
# ----------------
#
# Function to initialize yoda infrastructure
#
# .. code-block:: cmake
#
#   yoda_init()
#
function(yoda_init)

  yoda_get_compiler_info()
  yoda_get_platform_info()
  yoda_get_architecture_info()

  # Prevent in source builds
  yoda_check_in_source_build()
  
  # Output summary of the configuration
  macro(make_config_string FIRST SECOND)
    yoda_make_string_pair(${FIRST} ": ${SECOND}" 20 out)
    list(APPEND config_info ${out})
  endmacro()
  make_config_string("Platform" ${YODA_PLATFORM_STRING})
  make_config_string("Architecture" ${YODA_ARCHITECTURE_STRING})
  make_config_string("Compiler" ${YODA_COMPILER_STRING})
  # CMAKE_BUILD_TYPE can be empty
  if(${CMAKE_BUILD_TYPE})
    make_config_string("Build type" ${CMAKE_BUILD_TYPE})
  else()
    make_config_string("Build type" "")
  endif()
  yoda_report_result("Configuration summary" ${config_info})

endfunction()

