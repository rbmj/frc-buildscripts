@echo off

SCRIPT_DIR=%~dp0

CMAKE=%SCRIPT_DIR%\..\..\cmake\bin\cmake.exe
TOOLCHAIN_ROOT=%SCRIPT_DIR%\..\powerpc-wrs-vxworks
TOOLCHAIN_FILE=%TOOLCHAIN_ROOT%\share\cmake\toolchain.cmake

%CMAKE% -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN_FILE% -DCMAKE_INSTALL_PREFIX=%TOOLCHAIN_ROOT% %*

