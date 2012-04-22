cmake_minimum_required(VERSION 2.8)
# Toolchain File for VxWorks

include(CMakeForceCompiler)

### CONFIGURATION ###
set(CMAKE_SYSTEM_NAME vxWorks)
set(CMAKE_SYSTEM_VERSION 6) #TODO: get real version number
set(CMAKE_SYSTEM_PROCESSOR PPC)

set(TOOLCHAIN_PREFIX "/usr/local/powerpc-wrs-vxworks")
set(CMAKE_INSTALL_PREFIX ${TOOLCHAIN_PREFIX})
set(TOOLCHAIN_IS_GCCDIST false)
set(WIND_BASE "${TOOLCHAIN_PREFIX}/wind_base")
set(DEPLOYIP 10.6.12.2)

set(VXWORKS_USE_SOFT_FLOAT false)

CMAKE_FORCE_C_COMPILER(powerpc-wrs-vxworks-gcc GNU)
set(NM_EXECUTABLE powerpc-wrs-vxworks-nm)
set(OBJCOPY_EXECUTABLE powerpc-wrs-vxworks-objcopy)
set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PREFIX}")

#location of WPILib - this should become a .config or a find module!
set(WPILIB_LIBRARY "${TOOLCHAIN_PREFIX}/lib/libWPILib.a")
set(WPILIB_INCLUDE_DIR "${TOOLCHAIN_PREFIX}/include/WPILib")

### TOOLCHAIN SPECIFIC CONFIGURATION ###
if(${TOOLCHAIN_IS_GCCDIST})
	### CONFIGURATION FOR GCCDIST ONLY ###
	#nothing right now
else()
	### CONFIGURATION FOR NON-GCCDIST TOOLCHAINS ONLY ###
	set(VXWORKS_LIBSTDCXX "${TOOLCHAIN_PREFIX}/lib/libstdc++.a")
	set(VXWORKS_LIBSUPCXX "${TOOLCHAIN_PREFIX}/lib/libsupc++.a")
	set(VXWORKS_LIBGCC "/usr/local/lib/gcc/powerpc-wrs-vxworks/4.6.3/libgcc.a")

	#link flags for standard libraries
	set(VXWORKS_STDLIB_LINK " -lsupc++ -lstdc++ -lgcc")
	#TODO: Do we want libsupc++?
endif()
### END TOOLCHAIN SPECIFIC CONFIGURATION ###

### END CONFIGURATION ###

# (embedded) targets without operating system usually don't support shared libraries
SET_PROPERTY(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)
# is this true?  We can add a dependency on another kernel module, but it's crufty

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

#System Headers
if(${TOOLCHAIN_IS_GCCDIST})
	set(SYSTEM_INCLUDES " -isystem ${WIND_BASE}/target/h -isystem ${WIND_BASE}/target/h/wrn/coreip")
else()
	set(SYSTEM_INCLUDES " -isystem ${WIND_BASE}/target/h/wrn/coreip")
endif()

set(CPU PPC603)
set(TOOL_FAMILY gnu)
set(TOOL gnu)
set(ARCH_SPEC " -mcpu=603 -mstrict-align ${SOFT_FLOAT} -mlongcall")

if (${VXWORKS_USE_SOFT_FLOAT})
	set(ARCH_SPEC "${ARCH_SPEC} -msoft_float")
endif()

#Set CFLAGS, LDFLAGS
#Note that we use -nostdlib and then link with the standard library
set(VXWORKS_COMPILE_FLAGS " ${ARCH_SPEC} -nostdlib -ansi -Wall ${SYSTEM_INCLUDES} -DCPU=${CPU} -DTOOL_FAMILY=${TOOL_FAMILY} -DTOOL=${TOOL} -D_WRS_KERNEL")
set(VXWORKS_DKM_LINK_FLAGS " -nostdlib -r -Wl,-X -static") #should be equivalent to -nostdlib -Wl,-X,-r -static but I don't want to mess...
set(VXWORKS_DKM_LINK_SCRIPT_FLAG "-T ${WIND_BASE}/target/h/tool/gnu/ldscripts/link.OUT")

#Set CFLAGS, LDFLAGS
#Note that we use -nostdlib and then link with the standard library
set(VXWORKS_COMPILE_FLAGS " ${ARCH_SPEC} -nostdlib -ansi -Wall ${SYSTEM_INCLUDES} -DCPU=${CPU} -DTOOL_FAMILY=${TOOL_FAMILY} -DTOOL=${TOOL} -D_WRS_KERNEL")
set(VXWORKS_DKM_LINK_FLAGS " -nostdlib -r -Wl,-X -static") #should be equivalent to -nostdlib -Wl,-X,-r -static but I don't want to mess...
set(VXWORKS_DKM_LINK_SCRIPT_FLAG "-T ${WIND_BASE}/target/h/tool/gnu/ldscripts/link.OUT")

#Set toolchain definitions
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> <DEFINES> -c <SOURCE> -o <OBJECT> <FLAGS> ${VXWORKS_COMPILE_FLAGS}")
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> <DEFINES> -c <SOURCE> -o <OBJECT> <FLAGS> ${VXWORKS_COMPILE_FLAGS}")
set(CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS>" "<CMAKE_RANLIB> <TARGET>")
set(CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS>" "<CMAKE_RANLIB> <TARGET>")
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> ${VXWORKS_DKM_LINK_FLAGS} ${VXWORKS_DKM_LINK_SCRIPT_FLAG}")

#link rules for C++:
#TODO:  This will NOT work on win32!
if(${TOOLCHAIN_IS_GCCDIST})
#	Do a partial link.
#	- The first line compiles the partial image - NOTE: we link static libraries at this point so that all of
#		the symbols that are pulled into the module (and only those symbols) will be munched in the next step
#	- The second line "munches" the executable to generate a file (<TARGET>_ctdt.c) that contains all of the
#		static constructors and destructors in an array so that the kernel can call them at the appropriate times.
#	- The third line compiles the ctor/dtor file.
#	- The fourth line links the partial image together with the ctor/dtor object to create the finished executable
#	- The last line cleans up all these generated files (which will have to be regenerated later anyway)
#
#	NOTE: We don't link the standard library here as we'll get the kernel's copy when we get loaded in
	set(CMAKE_CXX_LINK_EXECUTABLE
		"<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> ${VXWORKS_DKM_LINK_FLAGS} <LINK_FLAGS> <OBJECTS> -o <TARGET>_PartialImage.out <LINK_LIBRARIES>"
		"${TOOLCHAIN_PREFIX}/munch.sh ${NM_EXECUTABLE} <TARGET>_ctdt.c <TARGET>_PartialImage.out"
		"<CMAKE_C_COMPILER> -c <TARGET>_ctdt.c -o <TARGET>_ctdt.c.o ${VXWORKS_COMPILE_FLAGS}"
		"<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <TARGET>_PartialImage.out <TARGET>_ctdt.c.o -o <TARGET> ${VXWORKS_DKM_LINK_FLAGS} ${VXWORKS_DKM_LINK_SCRIPT_FLAG}"
		"${CMAKE_COMMAND} -E remove <TARGET>_PartialImage.out <TARGET>_ctdt.c <TARGET>_ctdt.c.o"
	)
else()
#	Here's the crazy part...
#	- The first line compiles the partial image - NOTE: notice we also link the standard library at this point
#	- We munch the executable, which now contains the standard library as well
#	- The third line compiles the ctor/dtor file as above.
#	- The fourth line links the partial image together with the ctor/dtor object to create another partial image
#	- The fifth line localizes the symbols from the misc. standard libraries.  This is needed because if they are global
#		symbols then we'll get conflicts with the kernel's standard libraries as we share address space.  This is
#		what sucks about sharing address space with the kernel...
#	- The last line cleans up again.
#
#	NOTE: We need to link in our own standard library, both to get its features and because there might be some conflicts
#		in what symbols are defined, inline functions, and other internals between the kernel's stdlib (which is a whole
#		major version old!) and the one we have.  Even if its just the headers, something might break.  The gccdist link 
#		command might work, but I don't recommend it.
	set(CMAKE_CXX_LINK_EXECUTABLE 
		"<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> ${VXWORKS_DKM_LINK_FLAGS} <LINK_FLAGS> <OBJECTS> -o <TARGET>_PartialImage.out <LINK_LIBRARIES> ${VXWORKS_STDLIB_LINK}"
		"${TOOLCHAIN_PREFIX}/munch.sh ${NM_EXECUTABLE} <TARGET>_ctdt.c <TARGET>_PartialImage.out"
		"<CMAKE_C_COMPILER> -c <TARGET>_ctdt.c -o <TARGET>_ctdt.c.o ${VXWORKS_COMPILE_FLAGS}"
		"<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <TARGET>_PartialImage.out <TARGET>_ctdt.c.o -o <TARGET>_syms.out ${VXWORKS_DKM_LINK_FLAGS} ${VXWORKS_DKM_LINK_SCRIPT_FLAG}"
		"${TOOLCHAIN_PREFIX}/strip_syms.sh ${OBJCOPY_EXECUTABLE} ${NM_EXECUTABLE} <TARGET>_syms.out <TARGET> ${VXWORKS_LIBSTDCXX} ${VXWORKS_LIBSUPCXX} ${VXWORKS_LIBGCC}"
		"${CMAKE_COMMAND} -E remove <TARGET>_PartialImage.out <TARGET>_ctdt.c <TARGET>_ctdt.c.o <TARGET>_syms.out"
	)
endif()
set(CMAKE_LIBRARY_PATH_FLAG -L)