# - try to find GLOG headers
#
# Users may optionally supply:
#  GLOG_DIR - a prefix to start searching for the toon headers.
#
# Cache Variables: (probably not for direct use in your scripts)
#  GLOG_INCLUDE_DIR
#
# Non-cache variables you might use in your CMakeLists.txt:
#  GLOG_FOUND
#  GLOG_INCLUDE_DIRS
#  GLOG_LIBS
#  GLOG_DEFINES
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)

if(NOT GLOG_DIR OR "${GLOG_DIR}" STREQUAL "")
	set(GLOG_DIR "$ENV{GLOG_ROOT}")
endif()
set(GLOG_DIR "${GLOG_DIR}" CACHE PATH "Root directory of GLOG library")

###
# Configure GLOG
###
find_path(GLOG_INCLUDE_DIR
	NAMES "include/glog/logging.h"
	HINTS "${GLOG_DIR}" "$ENV{GLOG_ROOT}"
	PATH_SUFFIXES ""
	DOC "Root directory of GLOG library")
mark_as_advanced(GLOG_INCLUDE_DIR)

set(GLOG_FOUND FALSE)
if(EXISTS "${GLOG_INCLUDE_DIR}" AND NOT "${GLOG_INCLUDE_DIR}" STREQUAL "")
	set(GLOG_FOUND TRUE)

	find_library(GLOG_LIBRARY_DEBUG "libglog_static" "libglog" PATHS "${GLOG_DIR}/lib${PACKAGE_LIB_SUFFIX_DBG}" NO_DEFAULT_PATH)
	find_library(GLOG_LIBRARY_RELEASE "libglog_static" "libglog" PATHS "${GLOG_DIR}/lib${PACKAGE_LIB_SUFFIX_REL}" NO_DEFAULT_PATH)
	
	#Remove the cache value
	set(GLOG_LIBRARY "" CACHE STRING "" FORCE)
	
	#both debug/release
	if(GLOG_LIBRARY_DEBUG AND GLOG_LIBRARY_RELEASE)
		set(GLOG_LIBRARY debug ${GLOG_LIBRARY_DEBUG} optimized ${GLOG_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#only debug
	elseif(GLOG_LIBRARY_DEBUG)
		set(GLOG_LIBRARY ${GLOG_LIBRARY_DEBUG} CACHE STRING "" FORCE)
	#only release
	elseif(GLOG_LIBRARY_RELEASE)
		set(GLOG_LIBRARY ${GLOG_LIBRARY_RELEASE} CACHE STRING "" FORCE)
	#no library found
	else()
		message("GLOG library NOT found")
		set(GLOG_FOUND FALSE)
	endif()
	
	#Add to the general list
	if(GLOG_LIBRARY)
		set(GLOG_LIBS ${GLOG_LIBS} ${GLOG_LIBRARY})
	endif()
endif()

if(GLOG_FOUND)
	set(GLOG_INCLUDE_DIRS "${GLOG_INCLUDE_DIR}/include")
	set(GLOG_DIR "${GLOG_DIR}" CACHE PATH "" FORCE)
	set(GLOG_DEFINES "-DGOOGLE_GLOG_DLL_DECL=")
	mark_as_advanced(GLOG_DIR)
	message(STATUS "GLOG found (include: ${GLOG_INCLUDE_DIRS})")
else()
	package_report_not_found(GLOG "Please specify GLOG directory using GLOG_ROOT env. variable")
endif()
