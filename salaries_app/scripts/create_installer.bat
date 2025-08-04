@echo off
echo Creating Mini Mercado Balance Closing System Installer
echo =====================================================

REM Check if Inno Setup is installed
set "INNO_COMPILER="
for %%i in (
    "%ProgramFiles%\Inno Setup 6\ISCC.exe"
    "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
    "%ProgramFiles%\Inno Setup 5\ISCC.exe"
    "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
) do (
    if exist %%i (
        set "INNO_COMPILER=%%i"
        goto :found_inno
    )
)

echo Error: Inno Setup not found
echo Please download and install Inno Setup from: https://jrsoftware.org/isdl.php
echo.
echo After installation, run this script again.
pause
exit /b 1

:found_inno
echo Found Inno Setup at: %INNO_COMPILER%

REM Check if the build exists
if not exist "build\windows\x64\runner\Release\salaries_app.exe" (
    echo Error: Windows build not found. Please run build_installer.bat first.
    pause
    exit /b 1
)

REM Create installer directory if it doesn't exist
if not exist "installer" mkdir installer

REM Compile the installer
echo Compiling installer...
call "%INNO_COMPILER%" "setup.iss"

REM Check if compilation was successful
if exist "installer\MiniMercadoBalanceSetup.exe" (
    echo.
    echo ====================================================
    echo Installer created successfully!
    echo Location: installer\MiniMercadoBalanceSetup.exe
    echo ====================================================
    echo.
    echo You can now distribute this installer to users.
    echo.
) else (
    echo Error: Installer compilation failed
    pause
    exit /b 1
)

pause 