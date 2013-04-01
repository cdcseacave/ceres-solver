# - try to find GFLAGS headers
#
# Users may optionally supply:
#  GFLAGS_DIR - a prefix to start searching for the toon headers.
#
# Cache Variables: (probably not for direct use in your scripts)
#  GFLAGS_INCLUDE_DIR
#
# Non-cache variables you might use in your CMakeLists.txt:
#  GFLAGS_FOUND
#  GFLAGS_INCLUDE_DIRS
#  GFLAGS_LIBS
#  GFLAGS_DEFINES
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)

if(NOT GFLAGS_DIR OR "${GFLAGS_DIR}" STREQUAL "")
	set(GFLAGS_DIR "$ENV{GFLAGS_ROOT}")
endif()
set(GFLAGS_DIR "${GFLAGS_DIR}" CACHE PATH "Root directory of GFLAGS library")

###
# Configure GFLAGS
###
find_path(GFLAGS_INCLUDE_DIR
	NAMES "gflags/gflags.h"
	HINTS "${GFLAGS_DIR}" "$ENV{GFLAGS_ROOT}"
	PATH_SUFFIXES "include"
	DOC "Root directory of GFLAGS library")
mark_as_advanced(GFLAGS_INCLUDE_DIR)

set(GFLAGS_FOUND FALSE)
if(EXISTS "${GFLAGS_INCLUDE_DIR}" AND NOT "${GFLAGS_INCLUDE_DIR}" STREQUAL "")
	set(GFLAGS_FOUND TRUE)

	find_library(GFLAGS_LIBRARY_DEBUG "libgflags" PATHS "${GFLAGS_DIR}/lib${PACKAGE_LIB_SUFFIX_DBG}" NO_DEFAULT_PATH)
	find_library(GFLAGS_LIBRARY_RELEASE "libgflags" PATHS "${GFLAGS_DIR}/lib${PACKAGE_LIB_SUFFIX_REL}" NO_DEFAULT_PATH)
	
	#Remove the cache value
	set(GFLAGS_LIBRARY "" CACHE STRING "" FORCE)
	
	#both debug/release
	if(GFLAGS_LIBRARY_DEBUG AND GFLAGS_LIBRARY_RELEASE)
		set(GFLAGS_LIBRARY debug ${GFLAGS_LIBRARY_DEBUG} optimized ${GFLAGS_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#only debug
	elseif(GFLAGS_LIBRARY_DEBUG)
		set(GFLAGS_LIBRARY ${GFLAGS_LIBRARY_DEBUG} CACHE STRING "" FORCE)
	#only release
	elseif(GFLAGS_LIBRARY_RELEASE)
		set(GFLAGS_LIBRARY ${GFLAGS_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#no library found
	else()
		message("GFLAGS library NOT found")
		set(GFLAGS_FOUND FALSE)
	endif()
	
	#Add to the general list
	if(GFLAGS_LIBRARY)
		set(GFLAGS_LIBS ${GFLAGS_LIBS} ${GFLAGS_LIBRARY})
	endif()
endif()

if(GFLAGS_FOUND)
	set(GFLAGS_INCLUDE_DIRS "${GFLAGS_INCLUDE_DIR}")
	set(GFLAGS_DIR "${GFLAGS_DIR}" CACHE PATH "" FORCE)
	#set(GFLAGS_DEFINES "-DGFLAGS_LIB")
	mark_as_advanced(GFLAGS_DIR)
	message(STATUS "GFLAGS found (include: ${GFLAGS_INCLUDE_DIRS})")
else()
	package_report_not_found(GFLAGS "Please specify GFLAGS directory using GFLAGS_ROOT env. variable")
endif()
