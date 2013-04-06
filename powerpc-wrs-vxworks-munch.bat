@echo off

set TCL_SCRIPT=%WIND_BASE%\host\resource\hutils\tcl\munch.tcl
set OUTPUT_FILE=%1

REM Shift out first parameter
shift

REM set ARGS_REST to the remaining command-line parameters, properly escaped
REM Need this because %* does not obey shift as batch is a *stupid* shell
set ARGS_REST=
:next
shift
if [%0] == [] goto end
set ARGS_REST=%ARGS_REST% %0
goto next
:end

powerpc-wrs-vxworks-nm %ARGS_REST% | tclsh %TCL_SCRIPT% -c ppc | sed "s/extern void\(.*\);/extern void \1 __attribute__((externally_visible));/" > %OUTPUT_FILE%

