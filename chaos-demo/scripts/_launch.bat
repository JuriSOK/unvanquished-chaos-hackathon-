@echo off
rem Internal helper used by LAUNCH_CLEAN.bat / LAUNCH_BUGGED.bat.  Usage: _launch.bat clean^|bugged
setlocal
set VARIANT=%~1
if "%UNV_ROOT%"=="" set UNV_ROOT=C:\unv
set BUILD_DIR=%UNV_ROOT%\build-%VARIANT%
set GAME_HOME=%UNV_ROOT%\home-%VARIANT%
set PAK_DIR=%UNV_ROOT%\official\pkg
set REPO=%~dp0..

if not exist "%BUILD_DIR%\daemon.exe" (
  echo [%VARIANT%] "%BUILD_DIR%\daemon.exe" not found. Run SETUP.bat first.
  pause
  exit /b 1
)

rem One game instance at a time, so switching CLEAN/BUGGED is a single double-click.
taskkill /f /im daemon.exe >nul 2>&1

rem Offline demo layout: the only human telenode sits on the open-sky "23" landing pad.
if not exist "%GAME_HOME%\game\layouts\plat23" mkdir "%GAME_HOME%\game\layouts\plat23"
copy /y "%REPO%\config\layouts\plat23\chaos.dat" "%GAME_HOME%\game\layouts\plat23\chaos.dat" >nul

rem Mesa llvmpipe software OpenGL (the demo VM has no GPU). Ignored when Mesa's opengl32.dll is absent.
set GALLIUM_DRIVER=llvmpipe

cd /d "%BUILD_DIR%"
start "Unvanquished %VARIANT%" daemon.exe -homepath "%GAME_HOME%" -pakpath "%PAK_DIR%" ^
  -set vm.sgame.type 3 -set vm.cgame.type 3 ^
  -set r_fullscreen 0 -set r_mode -1 -set r_customwidth 1280 -set r_customheight 720 ^
  -set g_layouts chaos -set timelimit 0 -set g_neverEnd 1 -set g_doWarmup 0 ^
  +devmap plat23 +delay 150f "team humans" +delay 200f "class rifle"
endlocal
