###########################################################
#                  Find SUITESPARSE Library
# See http://sourceforge.net/projects/opencvlibrary/
#----------------------------------------------------------
#
## 1: Setup:
# The following variables are optionally searched for defaults
#  SUITESPARSE_DIR:            Base directory of OpenCv tree to use.
#
## 2: Variable
# The following are set after configuration is done: 
#  
#  SUITESPARSE_FOUND
#  SUITESPARSE_INCLUDE_DIRS
#  SUITESPARSE_LIBS
#  SUITESPARSE_DEFINITIONS
#
#----------------------------------------------------------

find_path(SUITESPARSE_DIR "include/CHOLMOD/Include/cholmod.h"
    HINTS "${SUITESPARSE_ROOT}" "$ENV{SUITESPARSE_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/SuiteSparse" "$ENV{PROGRAMW6432}/SuiteSparse"
    PATH_SUFFIXES 
    DOC "Root directory of SUITESPARSE library")

##====================================================
## Find SUITESPARSE libraries
##----------------------------------------------------
if(EXISTS "${SUITESPARSE_DIR}")

	## Initiate the variable before the loop
	set(SUITESPARSE_LIBS "")
	set(SUITESPARSE_FOUND TRUE)

	## Set all SUITESPARSE component and their account into variables
	set(SUITESPARSE_LIB_COMPONENTS amd camd colamd ccolamd cholmod SuiteSparse_config)

	## Loop over each internal component and find its library file
	foreach(LIBCOMP ${SUITESPARSE_LIB_COMPONENTS})

		find_library(SUITESPARSE_${LIBCOMP}_LIBRARY_DEBUG NAMES "${LIBCOMP}" PATHS "${SUITESPARSE_DIR}/lib${PACKAGE_LIB_SUFFIX_DBG}" NO_DEFAULT_PATH)
		find_library(SUITESPARSE_${LIBCOMP}_LIBRARY_RELEASE NAMES "${LIBCOMP}" PATHS "${SUITESPARSE_DIR}/lib${PACKAGE_LIB_SUFFIX_REL}" NO_DEFAULT_PATH)
		
		#Remove the cache value
		set(SUITESPARSE_${LIBCOMP}_LIBRARY "" CACHE STRING "" FORCE)
		
		#both debug/release
		if(SUITESPARSE_${LIBCOMP}_LIBRARY_DEBUG AND SUITESPARSE_${LIBCOMP}_LIBRARY_RELEASE)
			set(SUITESPARSE_${LIBCOMP}_LIBRARY debug ${SUITESPARSE_${LIBCOMP}_LIBRARY_DEBUG} optimized ${SUITESPARSE_${LIBCOMP}_LIBRARY_RELEASE} CACHE STRING "" FORCE)
		#only debug
		elseif(SUITESPARSE_${LIBCOMP}_LIBRARY_DEBUG)
			set(SUITESPARSE_${LIBCOMP}_LIBRARY ${SUITESPARSE_${LIBCOMP}_LIBRARY_DEBUG} CACHE STRING "" FORCE)
		#only release
		elseif(SUITESPARSE_${LIBCOMP}_LIBRARY_RELEASE)
			set(SUITESPARSE_${LIBCOMP}_LIBRARY ${SUITESPARSE_${LIBCOMP}_LIBRARY_RELEASE} CACHE STRING "" FORCE)
		#no library found
		else()
			message("SUITESPARSE component NOT found: ${LIBCOMP}")
			set(SUITESPARSE_FOUND FALSE)
		endif()
		
		#Add to the general list
		if(SUITESPARSE_${LIBCOMP}_LIBRARY)
			set(SUITESPARSE_LIBS ${SUITESPARSE_LIBS} ${SUITESPARSE_${LIBCOMP}_LIBRARY})
		endif()
			
	endforeach()

	set(SUITESPARSE_INCLUDE_DIRS "${SUITESPARSE_DIR}/include/SuiteSparse_config" "${SUITESPARSE_DIR}/include/AMD/Include" "${SUITESPARSE_DIR}/include/CAMD/Include" "${SUITESPARSE_DIR}/include/COLAMD/Include" "${SUITESPARSE_DIR}/include/CCOLAMD/Include" "${SUITESPARSE_DIR}/include/CHOLMOD/Include")
	message(STATUS "SUITESPARSE found (include: ${SUITESPARSE_INCLUDE_DIRS})")

else()

	package_report_not_found(SUITESPARSE "Please specify SUITESPARSE directory using SUITESPARSE_ROOT env. variable")

endif()
##====================================================


##====================================================
if(SUITESPARSE_FOUND)
	if(SYSTEM_USE_OPENBLAS)
	message("aaaaaaaaaaaaaaaaaaaaaaaa")
		FIND_PACKAGE(OpenBLAS QUIET)
		if(OpenBLAS_FOUND)
			set(SUITESPARSE_LIBS ${SUITESPARSE_LIBS} ${OpenBLAS_LIBS})
		endif()
	else()
		FIND_PACKAGE(LAPACK QUIET)
		if(LAPACK)
			set(SUITESPARSE_LIBS ${SUITESPARSE_LIBS} ${LAPACK_LIBS})
		endif()
	endif()
	FIND_PACKAGE(METIS QUIET)
	if(METIS_FOUND)
		set(SUITESPARSE_LIBS ${SUITESPARSE_LIBS} ${METIS_LIBS})
	endif()
	set(SUITESPARSE_DIR "${SUITESPARSE_DIR}" CACHE PATH "" FORCE)
	mark_as_advanced(SUITESPARSE_DIR)
endif()
##====================================================
