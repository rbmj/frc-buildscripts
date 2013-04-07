@echo off

set OBJ=%1
set SYMFILE=%TMP%\%RANDOM%.syms

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

powerpc-wrs-vxworks-echosyms %ARGS_REST% | sed "/^$/d" > %SYMFILE%

powerpc-wrs-vxworks-objcopy --localize-symbols=%SYMFILE% %OBJ%
del %SYMFILE%
