cmake_minimum_required(VERSION 2.8)
project(powerpc-wrs-vxworks-buildscripts)

set(CMAKE_INSTALL_PREFIX /usr)
set(TOOL_ROOT /usr/powerpc-wrs-vxworks)
set(CMAKE_TOOL_DIR ${TOOL_ROOT}/share/cmake)

#generate a toolchain file for the mythical "FRC" system
#so that the user can say set(CMAKE_SYSTEM_NAME FRC) to include it
set(PLATFORM_NAME_DECLARATION "") #will be in user CMakeLists.txt
set(PLATFORM_VERSION_DECLARATION "set(CMAKE_SYSTEM_VERSION 1)")
set(PLATFORM_PROCESSOR_DECLARATION "set(CMAKE_SYSTEM_PROFESSOR PPC)")

set(DEPLOY_MACRO_FILE "${CMAKE_CURRENT_SOURCE_DIR}/deploy_macro.cmake")
set(FRC_IN "${CMAKE_CURRENT_BINARY_DIR}/FRC.cmake.in")
set(FRC "${CMAKE_CURRENT_BINARY_DIR}/FRC.cmake")

configure_file(toolchain.cmake.in FRC.cmake.in @ONLY)
add_custom_command(OUTPUT FRC.cmake
	COMMAND cat "${FRC_IN}" "${DEPLOY_MACRO_FILE}" > "${FRC}"
	DEPENDS "${FRC_IN}"
)

#this will be a toolchain to be explicitly included
#not putting this in as an official cross toolchain as it's too
#application specific, but it can be included explicitly
set(PLATFORM_NAME_DECLARATION "set(CMAKE_SYSTEM_NAME VxWorks)")
set(PLATFORM_VERSION_DECLARATION "set(CMAKE_SYSTEM_VERSION 6)")
set(PLATFORM_PROCESSOR_DECLARATION "set(CMAKE_SYSTEM_PROCESSOR PPC)")

set(TOOLCHAIN_IN "${CMAKE_CURRENT_SOURCE_DIR}/toolchain.cmake.in")
set(TOOLCHAIN "${CMAKE_CURRENT_BINARY_DIR}/toolchain.cmake")
configure_file("${TOOLCHAIN_IN}" "${TOOLCHAIN}" @ONLY)

set(CLEANFILES "${TOOLCHAIN_IN}" "${FRC_IN}")
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${CLEANFILES}")

add_custom_target(CMAKE_TOOLCHAIN ALL DEPENDS ${FRC} ${TOOLCHAIN})

install(FILES "${FRC}" DESTINATION "${CMAKE_ROOT}/Modules/Platform")
install(FILES "${TOOLCHAIN}" DESTINATION "${CMAKE_TOOL_DIR}")
install(PROGRAMS "${CMAKE_CURRENT_SOURCE_DIR}/powerpc-wrs-vxworks-munch" DESTINATION bin)
install(PROGRAMS "${CMAKE_CURRENT_SOURCE_DIR}/powerpc-wrs-vxworks-stripsyms" DESTINATION bin)
