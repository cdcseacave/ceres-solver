# - try to find LAPACK headers
#
# Users may optionally supply:
#  LAPACK_DIR - a prefix to start searching for the toon headers.
#
# Cache Variables: (probably not for direct use in your scripts)
#  LAPACK_INCLUDE_DIR
#
# Non-cache variables you might use in your CMakeLists.txt:
#  LAPACK_FOUND
#  LAPACK_INCLUDE_DIRS
#  LAPACK_LIBS
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)

if(NOT LAPACK_DIR OR "${LAPACK_DIR}" STREQUAL "")
	set(LAPACK_DIR "$ENV{LAPACK_ROOT}")
endif()
set(LAPACK_DIR "${LAPACK_DIR}" CACHE PATH "Root directory of LAPACK library")

###
# Configure LAPACK
###
find_path(LAPACK_INCLUDE_DIR
	NAMES "clapack.h"
	HINTS "${LAPACK_DIR}" "$ENV{LAPACK_ROOT}"
	PATH_SUFFIXES include)
mark_as_advanced(LAPACK_INCLUDE_DIR)

set(LAPACK_FOUND FALSE)
if(EXISTS "${LAPACK_INCLUDE_DIR}" AND NOT "${LAPACK_INCLUDE_DIR}" STREQUAL "")
	set(LAPACK_FOUND TRUE)

	## Set all LAPACK component and their account into variables
	set(LAPACK_LIB_COMPONENTS blas f2c lapack)

	## Loop over each internal component and find its library file
	foreach(LIBCOMP ${LAPACK_LIB_COMPONENTS})
			
		find_library(LAPACK_${LIBCOMP}_LIBRARY_DEBUG NAMES "${LIBCOMP}" PATHS "${LAPACK_DIR}/lib${PACKAGE_LIB_SUFFIX_DBG}" NO_DEFAULT_PATH)
		find_library(LAPACK_${LIBCOMP}_LIBRARY_RELEASE NAMES "${LIBCOMP}" PATHS "${LAPACK_DIR}/lib${PACKAGE_LIB_SUFFIX_REL}" NO_DEFAULT_PATH)
		
		#Remove the cache value
		set(LAPACK_${LIBCOMP}_LIBRARY "" CACHE STRING "" FORCE)
		
		#both debug/release
		if(LAPACK_${LIBCOMP}_LIBRARY_DEBUG AND LAPACK_${LIBCOMP}_LIBRARY_RELEASE)
			set(LAPACK_${LIBCOMP}_LIBRARY debug ${LAPACK_${LIBCOMP}_LIBRARY_DEBUG} optimized ${LAPACK_${LIBCOMP}_LIBRARY_RELEASE} CACHE STRING "" FORCE)
		#only debug
		elseif(LAPACK_${LIBCOMP}_LIBRARY_DEBUG)
			set(LAPACK_${LIBCOMP}_LIBRARY ${LAPACK_${LIBCOMP}_LIBRARY_DEBUG} CACHE STRING "" FORCE)
		#only release
		elseif(LAPACK_${LIBCOMP}_LIBRARY_RELEASE)
			set(LAPACK_${LIBCOMP}_LIBRARY ${LAPACK_${LIBCOMP}_LIBRARY_RELEASE} CACHE STRING "" FORCE)
		#no library found
		else()
			message("LAPACK component NOT found: ${LIBCOMP}")
			set(LAPACK_FOUND FALSE)
		endif()
		
		#Add to the general list
		if(LAPACK_${LIBCOMP}_LIBRARY)
			set(LAPACK_LIBS ${LAPACK_LIBS} ${LAPACK_${LIBCOMP}_LIBRARY})
		endif()
			
	endforeach()
endif()

if(LAPACK_FOUND)
	set(LAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}")
	set(LAPACK_DIR "${LAPACK_DIR}" CACHE PATH "" FORCE)
	mark_as_advanced(LAPACK_DIR)
	message(STATUS "LAPACK found (include: ${LAPACK_INCLUDE_DIRS})")
else()
	package_report_not_found(LAPACK "Please specify LAPACK directory using LAPACK_ROOT env. variable")
endif()
