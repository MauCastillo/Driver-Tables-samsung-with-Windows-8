@if "%1" == "" goto noArguments

@REM Create target folder
mkdir %1

@REM Create Binary folder
mkdir %1\Bin

@REM Create Include files folder
mkdir %1\Include

@REM Create Source files folder
mkdir %1\Source

@REM Copy binaries
copy IgfxExt.exe %1\Bin
copy IgfxExps.dll %1\Bin

@REM Copy include files
copy Common.h %1\Include
copy IgfxExt.h %1\Include

@REM Copy source files
copy IgfxExt_i.c %1\Source

@REM Register server & proxy DLL
regsvr32 %1\Bin\IgfxExps.dll
%1\Bin\IgfxExt.exe /RegServer

@goto end

:noArguments
@echo Syntax:- Install [CuiSdkPath]

:end