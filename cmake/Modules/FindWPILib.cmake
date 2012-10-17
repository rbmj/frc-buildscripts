# CMake Find Module for WPILib by Matt Coffin
set(WPILib_FOUND 0)

# Common attributes
set(WPILib_SUFFIXES wpilib)

# Find includes
find_path(WPILib_INCLUDE_DIR
	NAMES WPILib.h
	PATH_SUFFIXES ${WPILib_SUFFIXES}
)

# Library
set(WPILib_NAMES wpilib libwpilib)
find_library(WPILib_LIBRARY
	NAMES ${WPILib_NAMES}
	PATHS /usr/lib /usr/local/lib /usr/local/powerpc-wrs-vxworks/lib
	PATH_SUFFIXES ${WPILib_SUFFIXES}
)

# Manage Output
if (WPILib_INCLUDE_DIR AND WPILib_LIBRARY)
	set(WPILib_FOUND true)
	set(WPILib_LIBRARIES ${WPILib_LIBRARY})
else (WPILib_INCLUDE_DIR AND WPILib_LIBRARY)
	set(WPILib_FOUND false)
	set( WPILib_LIBRARIES )
endif (WPILib_INCLUDE_DIR AND WPILib_LIBRARY)

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
