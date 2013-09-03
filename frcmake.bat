@echo off

SET SCRIPT_DIR=%~dp0

SET CMAKE=%SCRIPT_DIR%\..\..\cmake\bin\cmake.exe
SET TOOLCHAIN_ROOT=%SCRIPT_DIR%\..\powerpc-wrs-vxworks
SET TOOLCHAIN_FILE=%TOOLCHAIN_ROOT%\share\cmake\toolchain.cmake

"%CMAKE%" -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN_FILE% -DCMAKE_INSTALL_PREFIX=%TOOLCHAIN_ROOT% -G "MinGW Makefiles" %*

