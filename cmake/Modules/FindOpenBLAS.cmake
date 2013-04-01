# - try to find OpenBLAS headers
#
# Users may optionally supply:
#  OpenBLAS_DIR - a prefix to start searching for the toon headers.
#
# Cache Variables: (probably not for direct use in your scripts)
#  OpenBLAS_INCLUDE_DIR
#
# Non-cache variables you might use in your CMakeLists.txt:
#  OpenBLAS_FOUND
#  OpenBLAS_INCLUDE_DIRS
#  OpenBLAS_INCLUDES
#  OpenBLAS_LIBS
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)

if(NOT OpenBLAS_DIR OR "${OpenBLAS_DIR}" STREQUAL "")
	set(OpenBLAS_DIR "$ENV{OpenBLAS_ROOT}")
endif()
set(OpenBLAS_DIR "${OpenBLAS_DIR}" CACHE PATH "Root directory of OpenBLAS library")

###
# Configure OpenBLAS
###
find_path(OpenBLAS_INCLUDE_DIR
	NAMES "OpenBLAS/openblas_config.h"
	HINTS "${OpenBLAS_DIR}" "$ENV{OpenBLAS_ROOT}"
	PATH_SUFFIXES include)
mark_as_advanced(OpenBLAS_INCLUDE_DIR)

set(OpenBLAS_FOUND FALSE)
if(EXISTS "${OpenBLAS_INCLUDE_DIR}" AND NOT "${OpenBLAS_INCLUDE_DIR}" STREQUAL "")
	set(OpenBLAS_FOUND TRUE)

	if("${SYSTEM_BITNESS}" STREQUAL "64")
		set(PACKAGE_LIB_UNISUFFIX "/x64")
	else()
		set(PACKAGE_LIB_UNISUFFIX "/x86")
	endif()
	
	find_library(OpenBLAS_LIBRARY_DEBUG "libopenblas" "openblas" PATHS "${OpenBLAS_DIR}/lib${PACKAGE_LIB_UNISUFFIX}" NO_DEFAULT_PATH)
	find_library(OpenBLAS_LIBRARY_RELEASE "libopenblas" "openblas" PATHS "${OpenBLAS_DIR}/lib${PACKAGE_LIB_UNISUFFIX}" NO_DEFAULT_PATH)
	
	#Remove the cache value
	set(OpenBLAS_LIBRARY "" CACHE STRING "" FORCE)
	
	#both debug/release
	if(OpenBLAS_LIBRARY_DEBUG AND OpenBLAS_LIBRARY_RELEASE)
		set(OpenBLAS_LIBRARY debug ${OpenBLAS_LIBRARY_DEBUG} optimized ${OpenBLAS_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#only debug
	elseif(OpenBLAS_LIBRARY_DEBUG)
		set(OpenBLAS_LIBRARY ${OpenBLAS_LIBRARY_DEBUG} CACHE STRING "" FORCE)
	#only release
	elseif(OpenBLAS_LIBRARY_RELEASE)
		set(OpenBLAS_LIBRARY ${OpenBLAS_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#no library found
	else()
		message("OpenBLAS library NOT found")
		set(OpenBLAS_FOUND FALSE)
	endif()
	
	#Add to the general list
	if(OpenBLAS_LIBRARY)
		set(OpenBLAS_LIBS ${OpenBLAS_LIBS} ${OpenBLAS_LIBRARY})
	endif()
endif()

if(OpenBLAS_FOUND)
	set(OpenBLAS_INCLUDE_DIRS "${OpenBLAS_INCLUDE_DIR}")
	set(OpenBLAS_INCLUDE_FULLDIR "${OpenBLAS_DIR}/include/OpenBLAS/")
	set(OpenBLAS_INCLUDES "${OpenBLAS_INCLUDE_FULLDIR}cblas.h" "${OpenBLAS_INCLUDE_FULLDIR}f77blas.h" "${OpenBLAS_INCLUDE_FULLDIR}lapacke_utils.h")
	set(OpenBLAS_DIR "${OpenBLAS_DIR}" CACHE PATH "" FORCE)
	mark_as_advanced(OpenBLAS_DIR)
	message(STATUS "OpenBLAS found (include: ${OpenBLAS_INCLUDE_DIRS})")
else()
	package_report_not_found(OpenBLAS "Please specify OpenBLAS directory using OpenBLAS_ROOT env. variable")
endif()
