cmake_minimum_required(VERSION 2.8)
project(powerpc-wrs-vxworks-buildscripts)

#no need to type this out over and over again
set(SRCDIR "${CMAKE_CURRENT_SOURCE_DIR}")

#activate the windows section with a -D flag
if (${CROSS_BUILD_WINDOWS})
    set(CMAKE_DIR /cmake/share/cmake-2.8)
    set(CMAKE_INSTALL_PREFIX /mingw)
    set(TOOL_ROOT /mingw/powerpc-wrs-vxworks)
    set(MUNCH_SH "${SRCDIR}/powerpc-wrs-vxworks-munch.bat")
    set(STRIP_SH "${SRCDIR}/powerpc-wrs-vxworks-stripsyms.bat")
    set(ECHO_SH "${SRCDIR}/powerpc-wrs-vxworks-echosyms.bat")
    set(FRCMAKE_SH "${SRCDIR}/frcmake.bat")
else()
    set(CMAKE_INSTALL_PREFIX /usr)
    set(TOOL_ROOT /usr/powerpc-wrs-vxworks)
    set(CMAKE_DIR ${CMAKE_ROOT})
    set(MUNCH_SH "${SRCDIR}/powerpc-wrs-vxworks-munch")
    set(STRIP_SH "${SRCDIR}/powerpc-wrs-vxworks-stripsyms")
    set(FRCMAKE_SH "${SRCDIR}/frcmake")
endif()

set(CMAKE_TOOL_DIR ${TOOL_ROOT}/share/cmake)

#generate a toolchain file for the mythical "FRC" system
#so that the user can say set(CMAKE_SYSTEM_NAME FRC) to include it

#not doing this yet as I'm just using a wrapper script.  Not as nice,
#but it'll do for release while I figure out why this doesn't work...
#seems like you can't set the compiler in a platform description file

#set(PLATFORM_NAME_DECLARATION "") #will be in user CMakeLists.txt
#set(PLATFORM_VERSION_DECLARATION "set(CMAKE_SYSTEM_VERSION 1)")
#set(PLATFORM_PROCESSOR_DECLARATION "set(CMAKE_SYSTEM_PROFESSOR PPC)")

set(DEPLOY_MACRO_FILE "${SRCDIR}/FRCDeploy.cmake")
#set(FRC_IN "${CMAKE_CURRENT_BINARY_DIR}/FRC.cmake.in")
#set(FRC "${CMAKE_CURRENT_BINARY_DIR}/FRC.cmake")

#configure_file(toolchain.cmake.in FRC.cmake.in @ONLY)
#add_custom_command(OUTPUT FRC.cmake
#	COMMAND cat "${FRC_IN}" "${DEPLOY_MACRO_FILE}" > "${FRC}"
#	DEPENDS "${FRC_IN}"
#)

#this will be a toolchain to be explicitly included
#not putting this in as an official cross toolchain as it's too
#application specific, but it can be included explicitly
#using Generic in order to kill spurrious "we don't know this system" warns
set(PLATFORM_NAME_DECLARATION "set(CMAKE_SYSTEM_NAME Generic)") #VxWorks
set(PLATFORM_VERSION_DECLARATION "") #vxworks 6.3?
set(PLATFORM_PROCESSOR_DECLARATION "set(CMAKE_SYSTEM_PROCESSOR PPC)")

set(TOOLCHAIN_IN "${SRCDIR}/toolchain.cmake.in")
set(TOOLCHAIN "${CMAKE_CURRENT_BINARY_DIR}/toolchain.cmake")
configure_file("${TOOLCHAIN_IN}" "${TOOLCHAIN}" @ONLY)

set(CLEANFILES "${TOOLCHAIN_IN}") # "${FRC_IN}")
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${CLEANFILES}")

add_custom_target(CMAKE_TOOLCHAIN ALL DEPENDS ${TOOLCHAIN}) # ${FRC})

#install(FILES "${FRC}" DESTINATION "${CMAKE_ROOT}/Modules/Platform")
install(FILES "${DEPLOY_MACRO_FILE}" DESTINATION "${CMAKE_DIR}/Modules")
install(FILES "${TOOLCHAIN}" DESTINATION "${CMAKE_TOOL_DIR}")
install(PROGRAMS "${MUNCH_SH}" DESTINATION bin)
install(PROGRAMS "${STRIP_SH}" DESTINATION bin)
install(PROGRAMS "${FRCMAKE_SH}" DESTINATION bin)
if (${CROSS_BUILD_WINDOWS})
    install(PROGRAMS "${ECHO_SH}" DESTINATION bin)
endif()
