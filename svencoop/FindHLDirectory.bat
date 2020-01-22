@echo off
rem This batch file finds the Half-Life directory and returns it
rem If the directory could not be found, returns an empty value

set "RETURNVALUE="

setlocal enabledelayedexpansion
set KEY_NAME="HKEY_CURRENT_USER\Software\Valve\Steam"
set VALUE_NAME=ModInstallPath
set STEAM_PATH=SteamPath
set "HLSTEAMLIBDIR=steamapps\common\Half-Life"
set "STEAMLIBFILE=steamapps\libraryfolders.vdf"

rem Path relative to the default game or DS install.
set "RELATIVE_PATH=..\..\Half-Life"

FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%" 2^>nul ^| find "%VALUE_NAME%"') DO (set pInstallDir=%%B)

rem ModInstallPath search
IF "%pInstallDir%" == "" (
	ECHO Could not find %VALUE_NAME%. Trying to find game directory using relative path.
	IF EXIST %RELATIVE_PATH% (
		set "RETURNVALUE=%RELATIVE_PATH%"
		goto :returncall
	) else (
		echo Could not find game in the relative path. Trying to find game directory using Steam client path.
		goto :steamlib
	)
) ELSE (
	rem Got from ModInstallPath key
	set "RETURNVALUE=%pInstallDir%"
	goto :returncall
)

:steamlib
rem Figure out where Steam client is installed
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%STEAM_PATH%" 2^>nul ^| find "%STEAM_PATH%"') DO (set pSteamPath=%%B)

if "%pSteamPath%" == "" (
 	echo Steam client path not found. Unable to find any valid game installation.
 	goto :returncall
)

rem Is there a Half-Life install in the main library?
if exist "%pSteamPath%\%HLSTEAMLIBDIR%" (
	set "RETURNVALUE=%pSteamPath%\%HLSTEAMLIBDIR%"
	goto :returncall
)

rem Search through libraryfolders.vdf
set "LIBRARYFILE=%pSteamPath%\%STEAMLIBFILE%"
if exist "%LIBRARYFILE%" (
	for /F "tokens=2" %%L in ('findstr "[a-z]:" "%LIBRARYFILE%"') do (
		set "line=%%L"

		rem Replace double backquotes with single ones
		set "line=!line:\\=\!"

		rem Remove quotes
		set "line=!line:"=!"

		if exist "!line!\%HLSTEAMLIBDIR%" (
			rem Found Half-Life path on this library
			set "RETURNVALUE=!line!\%HLSTEAMLIBDIR%"
			goto :returncall
		)
	)
) else (
	echo Steam library file not found. Unable to find any valid game installation.
)

rem Return from caller
:returncall
ENDLOCAL&SET %~1=%RETURNVALUE%
