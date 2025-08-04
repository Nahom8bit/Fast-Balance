# Windows Installer Creation Guide

This guide explains how to create a Windows installer (.exe) for the Mini Mercado Balance Closing System.

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and configured for Windows development
2. **Inno Setup** - Download and install from [https://jrsoftware.org/isdl.php](https://jrsoftware.org/isdl.php)

## Quick Start

### Method 1: One-Command Build and Installer (Recommended)

**Complete build and installer creation in one command:**
```bash
cd salaries_app
scripts\build_and_install.bat
```

This will:
1. Clean previous builds
2. Get dependencies
3. Build the Windows app
4. Automatically create the installer (if Inno Setup is installed)

The installer will be created as `installer\MiniMercadoBalanceSetup.exe`

### Method 2: Separate Steps

1. **Build the Windows application:**
   ```bash
   cd salaries_app
   scripts\build_installer.bat
   ```

2. **Create the installer (if not done automatically):**
   ```bash
   scripts\create_installer.bat
   ```

### Method 2: Manual Process

1. **Build the Flutter app for Windows:**
   ```bash
   flutter clean
   flutter pub get
   flutter build windows --release
   ```

2. **Create the installer using Inno Setup:**
   - Open Inno Setup Compiler
   - Open `setup.iss`
   - Click Build > Compile
   - The installer will be created in the `installer` folder

## Installer Features

- **Modern UI** - Clean, professional installer interface
- **Automatic Installation** - Installs to Program Files by default
- **Desktop Shortcut** - Optional desktop icon creation
- **Start Menu Integration** - Adds to Windows Start Menu
- **Uninstall Support** - Proper uninstallation through Control Panel
- **64-bit Support** - Optimized for modern Windows systems

## Installer Configuration

The installer is configured in `setup.iss` with the following settings:

- **App Name:** Mini Mercado - Balance Closing System
- **Version:** 1.0.0
- **Publisher:** Mini Mercado
- **Default Install Location:** `C:\Program Files\Mini Mercado\Balance Closing System`
- **Compression:** LZMA (high compression)
- **Architecture:** 64-bit only

## Customization

### Changing App Information

Edit `setup.iss` to modify:
- App name and version
- Publisher information
- Install location
- Icons and shortcuts

### Adding License or Information Files

1. Create your license file (e.g., `LICENSE.txt`)
2. Update `setup.iss`:
   ```ini
   LicenseFile=LICENSE.txt
   ```

### Customizing the Installer

The installer script supports:
- Custom welcome and finish pages
- Additional file installations
- Registry modifications
- Custom installation tasks

## Troubleshooting

### Build Issues

1. **Flutter not found:**
   - Ensure Flutter is installed and in PATH
   - Run `flutter doctor` to verify installation

2. **Windows build fails:**
   - Install Visual Studio Build Tools
   - Enable Windows development in Flutter

### Installer Issues

1. **Inno Setup not found:**
   - Download and install Inno Setup
   - Ensure it's in the default installation path

2. **Compilation errors:**
   - Check that `balancer.exe` exists in `build\windows\runner\Release\`
   - Verify all required files are present

## Distribution

The created installer (`MiniMercadoBalanceSetup.exe`) can be:
- Distributed via email
- Uploaded to file sharing services
- Burned to CD/DVD
- Deployed via network installation

## File Structure

```
salaries_app/
├── setup.iss                    # Inno Setup configuration
├── scripts/
│   ├── build_and_install.bat   # One-command build and installer creation
│   ├── build_installer.bat     # Build automation script (includes installer)
│   └── create_installer.bat    # Installer creation script (standalone)
├── installer/                   # Output directory for installer
└── build/windows/runner/Release/ # Windows build output
```

## Version Management

To update the installer for a new version:

1. Update the version in `pubspec.yaml`
2. Update the version in `setup.iss`
3. Rebuild using the scripts
4. Test the new installer

## Support

For issues with the installer creation process:
1. Check the console output for error messages
2. Verify all prerequisites are installed
3. Ensure the Windows build completed successfully 