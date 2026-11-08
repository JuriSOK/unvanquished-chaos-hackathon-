@echo off
rem Usage: build.bat <source_dir> <build_dir>
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set PATH=C:\Program Files\CMake\bin;C:\ProgramData\chocolatey\bin;%PATH%
cmake -S "%~1" -B "%~2" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DBUILD_CLIENT=ON -DBUILD_SERVER=OFF -DBUILD_TTY_CLIENT=OFF ^
  -DBUILD_GAME_NACL=OFF -DBUILD_GAME_NATIVE_DLL=ON -DBUILD_GAME_NATIVE_EXE=OFF ^
  -DUSE_PRECOMPILED_HEADER=ON -DEXTERNAL_DEPS_DIR=C:/unv/external_deps || exit /b 1
cmake --build "%~2" --parallel 8 || exit /b 1
