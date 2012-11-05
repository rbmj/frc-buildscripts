# CMake Find Module for WPILib by Matt Coffin

# Common attributes
set(WPILib_SUFFIXES wpilib)
set(WPILib_NAMES wpilib libwpilib)

# Find includes
find_path(WPILib_INCLUDE_DIR
	NAMES WPILib.h
	PATH_SUFFIXES ${WPILib_SUFFIXES}
)

# Library
find_library(WPILib_LIBRARY
	NAMES ${WPILib_NAMES}
	PATHS /usr/lib /usr/local/lib /usr/local/powerpc-wrs-vxworks/lib
	PATH_SUFFIXES ${WPILib_SUFFIXES}
)

# Handle Args
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(WPILib DEFAULT_MSG WPILib_LIBRARY WPILib_INCLUDE_DIR)

if (WPILib_FOUND)
	set(WPILib_LIBRARIES ${WPILib_LIBRARY})
else (WPILib_FOUND)
	set( WPILib_LIBRARIES )
endif (WPILib_FOUND)

mark_as_advanced(
	WPILib_LIBRARY
	WPILib_INCLUDE_DIR
)
