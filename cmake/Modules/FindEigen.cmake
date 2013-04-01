###########################################################
#                  Find EIGEN Library
#----------------------------------------------------------

find_path(EIGEN_DIR "Eigen/Core"
    HINTS "${EIGEN_ROOT}" "$ENV{EIGEN_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/Eigen" "$ENV{PROGRAMW6432}/Eigen"
          "$ENV{PROGRAMFILES}/Eigen 3.0.0" "$ENV{PROGRAMW6432}/Eigen 3.0.0"
    PATH_SUFFIXES eigen3 include/eigen3 include
    DOC "Root directory of EIGEN library")

##====================================================
## Include EIGEN library
##----------------------------------------------------
if(EXISTS "${EIGEN_DIR}" AND NOT "${EIGEN_DIR}" STREQUAL "")
	set(EIGEN_FOUND TRUE)
	set(EIGEN_INCLUDE_DIRS ${EIGEN_DIR})
	set(EIGEN_DIR "${EIGEN_DIR}" CACHE PATH "" FORCE)
	mark_as_advanced(EIGEN_DIR)
	message(STATUS "Eigen found (include: ${EIGEN_INCLUDE_DIRS})")
else()
	package_report_not_found(EIGEN "Please specify EIGEN directory using EIGEN_ROOT env. variable")
endif()
##====================================================
