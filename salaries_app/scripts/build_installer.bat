@echo off
echo Building Mini Mercado Balance Closing System Installer
echo ====================================================

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Error: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

REM Clean previous builds
echo Cleaning previous builds...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build for Windows
echo Building for Windows...
flutter build windows --release

REM Check if build was successful
if not exist "build\windows\x64\runner\Release\salaries_app.exe" (
    echo Error: Build failed - salaries_app.exe not found
    pause
    exit /b 1
)

echo Build completed successfully!
echo.

REM Check if Inno Setup is installed and create installer automatically
set "INNO_COMPILER="
for %%i in (
    "%ProgramFiles%\Inno Setup 6\ISCC.exe"
    "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
    "%ProgramFiles%\Inno Setup 5\ISCC.exe"
    "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
) do (
    if exist %%i (
        set "INNO_COMPILER=%%i"
        goto :create_installer
    )
)

echo Inno Setup not found. Installer creation skipped.
echo To create the installer manually:
echo 1. Download and install Inno Setup from: https://jrsoftware.org/isdl.php
echo 2. Open setup.iss in Inno Setup Compiler
echo 3. Click Build > Compile
echo 4. The installer will be created in the installer folder
echo.
pause
exit /b 0

:create_installer
echo Found Inno Setup at: %INNO_COMPILER%
echo Creating installer...

REM Create installer directory if it doesn't exist
if not exist "installer" mkdir installer

REM Compile the installer
"%INNO_COMPILER%" "setup.iss"

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