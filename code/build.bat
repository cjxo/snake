@echo off
setlocal enabledelayedexpansion

if not exist ..\build mkdir ..\build
pushd ..\build
ml64 /nologo /Fesnake.exe /Flsnakeasmlisting.txt /Fmsnakelinkermap.txt /W3 /Zi ..\code\main.asm /link /incremental:no /nodefaultlib /subsystem:windows Kernel32.lib user32.lib gdi32.lib winmm.lib
rem cl /nologo /Zi /Od /W4 /FAs /Famain.asm ..\code\main.c /link /nodefaultlib /subsystem:windows kernel32.lib user32.lib gdi32.lib
if "%1"=="r" (
    snake.exe
)
popd

endlocal

rem if not "%errorlevel%"=="0" (
rem  exit \b 1
rem )
