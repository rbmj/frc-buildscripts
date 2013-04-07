@echo off
FOR /F "usebackq tokens=3 delims= " %%s IN (`powerpc-wrs-vxworks-nm %*`) DO echo %%s
