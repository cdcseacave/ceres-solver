# - try to find METIS headers
#
# Users may optionally supply:
#  METIS_DIR - a prefix to start searching for the toon headers.
#
# Cache Variables: (probably not for direct use in your scripts)
#  METIS_INCLUDE_DIR
#
# Non-cache variables you might use in your CMakeLists.txt:
#  METIS_FOUND
#  METIS_INCLUDE_DIRS
#  METIS_LIBS
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)

if(NOT METIS_DIR OR "${METIS_DIR}" STREQUAL "")
	set(METIS_DIR "$ENV{METIS_ROOT}")
endif()
set(METIS_DIR "${METIS_DIR}" CACHE PATH "Root directory of METIS library")

###
# Configure METIS
###
find_path(METIS_INCLUDE_DIR
	NAMES "metis/metis.h"
	HINTS "${METIS_DIR}" "$ENV{METIS_ROOT}"
	PATH_SUFFIXES include)
mark_as_advanced(METIS_INCLUDE_DIR)

set(METIS_FOUND FALSE)
if(EXISTS "${METIS_INCLUDE_DIR}" AND NOT "${METIS_INCLUDE_DIR}" STREQUAL "")
	set(METIS_FOUND TRUE)

	find_library(METIS_LIBRARY_DEBUG "metisLib" "metis" "libmetis" "graclus" PATHS "${METIS_DIR}/lib${PACKAGE_LIB_SUFFIX_DBG}" NO_DEFAULT_PATH)
	find_library(METIS_LIBRARY_RELEASE "metisLib" "metis" "libmetis" "graclus" PATHS "${METIS_DIR}/lib${PACKAGE_LIB_SUFFIX_REL}" NO_DEFAULT_PATH)
	
	#Remove the cache value
	set(METIS_LIBRARY "" CACHE STRING "" FORCE)
	
	#both debug/release
	if(METIS_LIBRARY_DEBUG AND METIS_LIBRARY_RELEASE)
		set(METIS_LIBRARY debug ${METIS_LIBRARY_DEBUG} optimized ${METIS_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#only debug
	elseif(METIS_LIBRARY_DEBUG)
		set(METIS_LIBRARY ${METIS_LIBRARY_DEBUG} CACHE STRING "" FORCE)
	#only release
	elseif(METIS_LIBRARY_RELEASE)
		set(METIS_LIBRARY ${METIS_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#no library found
	else()
		message("METIS library NOT found")
		set(METIS_FOUND FALSE)
	endif()
	
	#Add to the general list
	if(METIS_LIBRARY)
		set(METIS_LIBS ${METIS_LIBS} ${METIS_LIBRARY})
	endif()
endif()

if(METIS_FOUND)
	set(METIS_INCLUDE_DIRS "${METIS_INCLUDE_DIR}")
	set(METIS_DIR "${METIS_DIR}" CACHE PATH "" FORCE)
	mark_as_advanced(METIS_DIR)
	message(STATUS "METIS found (include: ${METIS_INCLUDE_DIRS})")
else()
	package_report_not_found(METIS "Please specify METIS directory using METIS_ROOT env. variable")
endif()
