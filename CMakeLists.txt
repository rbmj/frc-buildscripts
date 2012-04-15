cmake_minimum_required(VERSION 2.8)
# Toolchain File for FRC
include(CMakeForceCompiler)

#is there a cmake variable for nm?
set(NM_PROGRAM powerpc-wrs-vxworks-nm)

#information needed by cmake:
set(CMAKE_SYSTEM_NAME vxWorks)
set(CMAKE_SYSTEM_VERSION 6) #TODO: get real version number
set(CMAKE_SYSTEM_PROCESSOR PPC)

#system wide settings
set(TOOLCHAIN_PREFIX "/usr/local/powerpc-wrs-vxworks")
set(WIND_BASE "${TOOLCHAIN_PREFIX}/wind_base")
set(DEPLOYIP 10.6.12.2)

set(VXWORKS_USE_SOFT_FLOAT false)

#set compiler
CMAKE_FORCE_C_COMPILER(powerpc-wrs-vxworks-gcc GNU)
set(NM_EXECUTABLE powerpc-wrs-vxworks-nm)
set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PREFIX}")

#set necessary internal cmake flags
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> <DEFINES> <SOURCE> -o <OBJECT> <FLAGS>")
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> <DEFINES> <SOURCE> -o <OBJECT> <FLAGS>")
set(CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS>" "<CMAKE_RANLIB> <TARGET>")
set(CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS>" "<CMAKE_RANLIB> <TARGET>")
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER>  <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_LIBRARY_PATH_FLAG -L)

# (embedded) targets without operating system usually don't support shared libraries
SET_PROPERTY(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

# To help the find_xxx() commands, set at least the following so CMAKE_FIND_ROOT_PATH
# works at least for some simple cases:
SET(CMAKE_SYSTEM_INCLUDE_PATH /include )
SET(CMAKE_SYSTEM_LIBRARY_PATH /lib )
SET(CMAKE_SYSTEM_PROGRAM_PATH /bin )

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

#config
set(SYSTEM_INCLUDES " -I${WIND_BASE}/target/h -I${WIND_BASE}/target/h/wrn/coreip")
set(WPILIB_LIBRARY "${WIND_BASE}/vxworks-6.3/target/lib/WPILib.a")
set(WPILIB_INCLUDE_DIR "${WIND_BASE}/vxworks-6.3/target/h/WPILib")
set(CPU PPC603)
set(TOOL_FAMILY gnu)
set(TOOL gnu)
set(ARCH_SPEC " -mcpu=603 -mstrict-align ${SOFT_FLOAT} -mlongcall")

if (${VXWORKS_USE_SOFT_FLOAT})
	set(ARCH_SPEC "${ARCH_SPEC} -msoft_float")
endif()

#Add a VxWorks Downloadable Kernel Module Target
macro(add_vxworks_dkm TGTNAME SOURCES INCLUDES LIBS)
	#TODO: Set these CFLAGS better...
	add_executable(${TGTNAME}_PartialImage ${SOURCES})
	set_target_properties(${TGTNAME}_PartialImage PROPERTIES SUFFIX .o)
	target_link_libraries(${TGTNAME}_PartialImage ${LIBS})
	include_directories(${INCLUDES})
	#add circular dependency on purpose to tell CMake to shut up that it doesn't know where FRC_PartialImage.o come from. Bug?
	add_custom_command(
		OUTPUT ${TGTNAME}_PartialImage.o
		COMMAND echo #reasonably cross platform noop
		DEPENDS ${TGTNAME}_PartialImage
	)
	add_custom_command(
		OUTPUT ctdt.c
		COMMAND ${NM_EXECUTABLE} ${TGTNAME}_PartialImage.o | tclsh ${WIND_BASE}/host/resource/hutils/tcl/munch.tcl -c ppc > ctdt.c
		DEPENDS ${TGTNAME}_PartialImage.o
	)
	add_executable(${TGTNAME} ctdt.c ${TGTNAME}_PartialImage.o)
	set_target_properties(${TGTNAME} PROPERTIES SUFFIX .out)
	set_target_properties(${TGTNAME} PROPERTIES LINK_FLAGS "-T ${WIND_BASE}/target/h/tool/gnu/ldscripts/link.OUT")
	set_target_properties(${TGTNAME} PROPERTIES COMPILE_FLAGS "-nostdlib")

	#Set CFLAGS

	set(CMAKE_C_FLAGS " ${ARCH_SPEC} -ansi -Wall ${SYSTEM_INCLUDES} -DCPU=${CPU} -DTOOL_FAMILY=${TOOL_FAMILY} -DTOOL=${TOOL} -D_WRS_KERNEL")
	set(CMAKE_CXX_FLAGS " ${ARCH_SPEC} -ansi -Wall ${SYSTEM_INCLUDES} -DCPU=${CPU} -DTOOL_FAMILY=${TOOL_FAMILY} -DTOOL=${TOOL} -D_WRS_KERNEL")
	set(CMAKE_EXE_LINKER_FLAGS " -r -nostdlib -Wl,-X -T ${WIND_BASE}/target/h/tool/gnu/ldscripts/link.OUT")

	set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS} -g")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -g")
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS} -g")
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS} -O2 -fstrength-reduce -fno-builtin")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O2 -fstrength-reduce -fno-builtin")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS} -O2 -fstrength-reduce -fno-builtin")

endmacro(ADD_FRC)

#project specific
project(FRC)
set(FRC_SOURCES main.cpp)
set(FRC_INCLUDES ${WPILIB_INCLUDE_DIR})
set(FRC_LIBS ${WPILIB_LIBRARY})
add_vxworks_dkm(FRC_UserProgram ${FRC_SOURCES} ${FRC_INCLUDES} ${FRC_LIBS})


