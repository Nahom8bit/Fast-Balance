# Build Troubleshooting Guide

## Common Windows Build Issues and Solutions

### Issue 1: Native Assets Directory Missing

**Error Message:**
```
CMake Error at cmake_install.cmake:233 (file):
  file INSTALL cannot find
  "D:/Projects/Systems/Salaries/salaries_app/build/native_assets/windows": No such file or directory.
```

**Root Cause:**
Flutter's Windows build process expects a `native_assets/windows` directory in the build folder, but this directory is not always created automatically.

**Solution:**
```bash
# Create the missing directory
mkdir -p build/native_assets/windows

# Then retry the build
flutter build windows --release
```

**PowerShell Version:**
```powershell
# Create the missing directory
New-Item -ItemType Directory -Force -Path "build\native_assets\windows"

# Then retry the build
flutter build windows --release
```

### Issue 2: Visual Studio Build Tools Not Found

**Error Message:**
```
No Visual Studio installation found.
```

**Solution:**
1. Install Visual Studio Community 2022 with C++ desktop development workload
2. Or install Visual Studio Build Tools with the following components:
   - Microsoft.VisualStudio.Workload.NativeDesktop
   - Microsoft.VisualStudio.Component.VC.Tools.x86.x64
   - Microsoft.VisualStudio.Component.VC.CMake.Project

### Issue 3: CMake Not Found

**Error Message:**
```
CMake is required to build the Windows project.
```

**Solution:**
1. Install Visual Studio with C++ CMake tools
2. Or manually install CMake and add to PATH
3. Restart your terminal/IDE after installation

### Issue 4: Flutter Windows Dependencies

**Error Message:**
```
No Windows desktop project available.
```

**Solution:**
```bash
# Enable Windows desktop support
flutter config --enable-windows-desktop

# Create Windows runner (if missing)
flutter create --platforms=windows .
```

### Issue 5: Permission Errors During Build

**Error Message:**
```
Access denied. Cannot delete build files.
```

**Solution:**
1. Close any running instances of the app
2. Run terminal as Administrator
3. Clear build cache:
```bash
flutter clean
flutter pub get
flutter build windows --release
```

### Issue 6: Antivirus Blocking Build

**Symptoms:**
- Build process hangs
- Files randomly disappear during build
- Access denied errors

**Solution:**
1. Temporarily disable real-time protection
2. Add project folder to antivirus exclusions
3. Add Flutter SDK folder to exclusions

## Build Verification

After successful build, verify these files exist:

```
build/windows/x64/runner/Release/
├── salaries_app.exe                    # Main executable
├── flutter_windows.dll                 # Flutter runtime
├── pdfium.dll                          # PDF support
├── printing_plugin.dll                 # Print support
├── url_launcher_windows_plugin.dll     # URL handling
└── data/                               # Application assets
    ├── app.so                          # Compiled Dart code
    ├── icudtl.dat                      # Internationalization data
    └── flutter_assets/                 # UI assets
```

## Build Script for Automation

Create a `build.bat` file for automated builds:

```batch
@echo off
echo Building Mini Mercado Windows Release...

echo Step 1: Cleaning previous build...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Creating native assets directory...
if not exist "build\native_assets\windows" mkdir "build\native_assets\windows"

echo Step 4: Building Windows release...
flutter build windows --release

echo Step 5: Checking build results...
if exist "build\windows\x64\runner\Release\salaries_app.exe" (
    echo ✅ Build successful!
    echo Executable size:
    dir "build\windows\x64\runner\Release\salaries_app.exe"
) else (
    echo ❌ Build failed - executable not found
    exit /b 1
)

pause
```

## Performance Optimization

For faster builds:

1. **Use Release Mode:**
   ```bash
   flutter build windows --release
   ```

2. **Skip Unnecessary Steps:**
   ```bash
   flutter build windows --release --no-tree-shake-icons
   ```

3. **Parallel Building:**
   ```bash
   flutter build windows --release --dart-define=flutter.inspector.structuredErrors=false
   ```

## Debug Build Issues

For debugging build problems:

1. **Verbose Output:**
   ```bash
   flutter build windows --release --verbose
   ```

2. **Check Dependencies:**
   ```bash
   flutter doctor -v
   ```

3. **Verify Windows Setup:**
   ```bash
   flutter config --enable-windows-desktop
   flutter doctor --verbose
   ```

## Common File Paths

Important paths to check:

- **Flutter SDK:** `%LOCALAPPDATA%\flutter`
- **Pub Cache:** `%LOCALAPPDATA%\Pub\Cache`
- **Visual Studio:** `C:\Program Files\Microsoft Visual Studio\2022\Community`
- **CMake:** `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin`

## Success Indicators

Build is successful when you see:
```
Building Windows application...                                     X.Xs
√ Built build\windows\x64\runner\Release\salaries_app.exe
```

## Contact Support

If issues persist:
1. Check Flutter GitHub issues for similar problems
2. Run `flutter doctor -v` and include output in bug reports
3. Include full build log when reporting issues
4. Mention Windows version and Visual Studio version

## Version Compatibility

Tested Configurations:
- **Flutter:** 3.24.5+
- **Dart:** 3.6.1+
- **Visual Studio:** 2022 Community/Professional
- **Windows:** 10 (1903+) and 11
- **CMake:** 3.20+

---

**Last Updated:** August 20, 2025
**Applies To:** Mini Mercado Balance Closing System v2.0.0
