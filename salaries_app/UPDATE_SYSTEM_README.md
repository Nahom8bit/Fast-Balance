# 🔄 Auto-Update System for Mini Mercado App

## 📋 Overview

The Mini Mercado app now includes an automatic update system that checks for new versions from GitHub releases and prompts users to download updates.

## 🚀 Features

- ✅ **Automatic Update Checks**: Checks for updates daily when the app starts
- ✅ **Manual Update Check**: Users can manually check for updates in Settings
- ✅ **Update Dialog**: Beautiful dialog showing version info and release notes
- ✅ **Direct Download**: Opens GitHub release page for easy download
- ✅ **Smart Versioning**: Compares semantic versions (1.0.0, 1.1.0, etc.)

## 🛠️ Setup Instructions

### 1. Create GitHub Repository

1. Create a new GitHub repository named `mini-mercado-app`
2. Make it public or private (your choice)

### 2. Update the GitHub URL

Edit `lib/update_service.dart` and replace the GitHub URL:

```dart
static const String _githubApiUrl = 'https://api.github.com/repos/YOUR_USERNAME/mini-mercado-app/releases/latest';
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### 3. Create GitHub Releases

When you want to release an update:

1. **Tag your release** with semantic versioning:
   - `v1.0.1` for bug fixes
   - `v1.1.0` for new features
   - `v2.0.0` for major changes

2. **Add release notes** in the GitHub release description:
   ```
   🎉 New Features:
   - Added Kwanza currency support
   - Improved dashboard performance
   
   🐛 Bug Fixes:
   - Fixed chart scaling issues
   - Resolved UI overflow problems
   ```

3. **Upload the Windows executable**:
   - Build: `flutter build windows --release`
   - Upload the `.exe` file from `build/windows/x64/runner/Release/`

### 4. Version Management

The app checks for updates by comparing versions:
- Current version: `1.0.0` (in `update_service.dart`)
- GitHub release tag: `v1.0.1` → becomes `1.0.1`
- If GitHub version > Current version → Update available

## 📱 How It Works

### Automatic Checks
- App checks for updates once per day
- Checks happen when the login screen loads
- No internet connection required (fails gracefully)

### Manual Checks
- Users can check for updates in Settings
- Shows loading indicator during check
- Displays "You're up to date" or update dialog

### Update Dialog
- Shows new version number
- Displays release notes from GitHub
- "Later" button dismisses dialog
- "Download Update" opens GitHub release page

## 🔧 Configuration Options

### Update Check Frequency
Edit `update_service.dart` to change check frequency:

```dart
// Check once per day (24 hours)
return difference.inHours >= 24;

// Check once per week
return difference.inHours >= 168;

// Check every time app starts
return true;
```

### Current Version
Update the current version in `update_service.dart`:

```dart
static const String _currentVersion = '1.0.0';
```

## 📦 Release Process

### 1. Update Version
```dart
// In update_service.dart
static const String _currentVersion = '1.1.0';
```

### 2. Build Release
```bash
flutter build windows --release
```

### 3. Create GitHub Release
- Tag: `v1.1.0`
- Title: `Mini Mercado v1.1.0`
- Description: Release notes
- Upload: `salaries_app.exe`

### 4. Test Update
- Install old version
- Start app
- Should see update dialog
- Click "Download Update"
- Should open GitHub release page

## 🐛 Troubleshooting

### Update Not Showing
1. Check GitHub URL is correct
2. Verify release tag format (`v1.0.1`)
3. Ensure release is published (not draft)
4. Check internet connection

### App Crashes on Update Check
1. Network errors are handled silently
2. Check GitHub API rate limits
3. Verify JSON response format

### Manual Check Not Working
1. Check internet connection
2. Verify GitHub repository exists
3. Ensure release is public

## 🔒 Security Notes

- Update checks use public GitHub API
- No authentication required
- Release notes are displayed as-is from GitHub
- Download links open in external browser
- No automatic installation (user must manually download)

## 📈 Future Enhancements

- [ ] Automatic download and installation
- [ ] Update notifications
- [ ] Rollback to previous version
- [ ] Beta channel support
- [ ] Update progress tracking

## 📞 Support

If you encounter issues with the update system:
1. Check GitHub repository settings
2. Verify release tag format
3. Test with a simple release first
4. Check network connectivity

---

**Note**: The update system is designed to be simple and reliable. It doesn't automatically install updates for security reasons - users must manually download and install new versions. 