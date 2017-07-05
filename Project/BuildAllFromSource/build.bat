@echo off

rem ***********************************************************************************************
rem * build.bat - Batch script for building Windows version of QCTools                            *
rem *                                                                                             *
rem *Script requirements:                                                                         *
rem * - Microsoft Visual Studio 2015 at the default place                                         *
rem * - qctools_AllInclusive source tree                                                          *
rem * - Qt bin directory corresponding to the requested build type (static or shared, x86 or x64) *
rem *   in the PATH                                                                               *
rem * - Cygwin directory with bash, sed, make and diffutils in the PATH                           *
rem * - yasm.exe in the PATH if not provided by Cygwin                                            *
rem * Options:                                                                                    *
rem * - /static           - build statically linked binary                                        *
rem * - /target x86|x64   - target arch (default x86)                                             *
rem ***********************************************************************************************

rem *** Init ***
set ARCH=x86
set STATIC=

set OLD_CD="%CD%"
set OLD_PATH=%PATH%
set BUILD_DIR="%~dp0..\..\.."

set CHERE_INVOKING=1

rem *** Initialize bash user files (needed to make CHERE_INVOKING work) ***
bash --login -c "exit"

rem *** Parse command line ***
:cmdline
if not "%1"=="" (
    if /I "%1"=="/static" set STATIC=1
    if /I "%1"=="/target" (
        set ARCH=%2
        shift
    )
    shift
    goto:cmdline
)

if not "%ARCH%"=="x86" if not "%ARCH%"=="x64" (
    echo ERROR: Unknown value for arch %ARCH%
    goto:clean
)

if "%ARCH%"=="x86" set PLATFORM=Win32
if "%ARCH%"=="x64" set PLATFORM=x64

rem *** Get VC tools path ***
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %ARCH%

rem *** Build ffmpeg ***
cd "%BUILD_DIR%\ffmpeg"

set FFMPEG_CMDLINE=--prefix^=. --disable-programs --enable-gpl --enable-version3 --toolchain^=msvc
set FFMPEG_CMDLINE=%FFMPEG_CMDLINE% --disable-securetransport --disable-videotoolbox
set FFMPEG_CMDLINE=%FFMPEG_CMDLINE% --disable-doc --disable-ffplay --disable-ffprobe --disable-ffserver --disable-debug
set FFMPEG_CMDLINE=%FFMPEG_CMDLINE% --enable-libfreetype --extra-cflags^=-I../freetype/include

rem *** Build freetype ***
cd "%BUILD_DIR%\freetype\builds\windows\vc2010"
    sed -i "s/>v100</>v140</g" freetype.vcxproj
if defined STATIC (
    sed -i "s/>MultiThreadedDLL</>MultiThreaded</g" freetype.vcxproj
) else (
    sed -i "s/>MultiThreaded</>MultiThreadedDLL</g" freetype.vcxproj
)

MSBuild /t:Clean;Build /p:Configuration=Release;Platform=%PLATFORM%

rem *** Build ffmpeg ***
cd "%BUILD_DIR%\ffmpeg"
if defined STATIC (
    set FFMPEG_CMDLINE=%FFMPEG_CMDLINE% --enable-static --disable-shared
) else (
    set FFMPEG_CMDLINE=%FFMPEG_CMDLINE% --enable-shared --disable-static
)

if exist Makefile bash --login -c "make clean uninstall"
bash --login -c "./configure %FFMPEG_CMDLINE%"
bash --login -c "make install"

if defined STATIC forfiles /S /M *.a /C "cmd /c rename @file ///*.lib"

rem *** Build qwt ***
cd "%BUILD_DIR%\qwt"
rem TODO: Make dynamically linked version of QWT work
if exist Makefile nmake distclean

qmake -recursive
nmake Release

rem *** Build QCTools ***
cd "%BUILD_DIR%\qctools\Project\QtCreator"
if exist Makefile nmake distclean

qmake QMAKE_CXXFLAGS+=/Zi QMAKE_LFLAGS+=/INCREMENTAL:NO QMAKE_LFLAGS+=/Debug
nmake

rem *** Cleaning ***
:clean
set PATH=%OLD_PATH%
cd %OLD_CD%
