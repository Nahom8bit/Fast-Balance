# Installation Guide - Mini Mercado Balance Closing System v2.1.0

## 📋 System Requirements

Before installing, ensure your system meets these requirements:

### Minimum Requirements
- **Operating System**: Windows 10 (64-bit) or newer
- **RAM**: 4GB minimum
- **Storage**: 100MB free disk space
- **Processor**: Intel/AMD x64 compatible
- **Permissions**: Administrator rights for installation

### Recommended Requirements
- **Operating System**: Windows 11 (64-bit)
- **RAM**: 8GB or more
- **Storage**: 500MB free disk space (for data and updates)
- **Processor**: Modern multi-core processor
- **Network**: Internet connection for updates

## 🚀 Installation Methods

### Method 1: Windows Installer (Recommended)

1. **Download the Installer**
   - Download `MiniMercadoBalanceSetup.exe` from the release
   - Save to a location you can easily find (Downloads folder)

2. **Run the Installer**
   - Right-click on `MiniMercadoBalanceSetup.exe`
   - Select "Run as administrator"
   - If Windows Defender shows a warning, click "More info" → "Run anyway"

3. **Follow Installation Wizard**
   - Welcome screen: Click "Next"
   - License agreement: Accept and click "Next"
   - Installation directory: Use default or choose custom location
   - Start menu folder: Use default or customize
   - Additional tasks: Check "Create desktop icon" if desired
   - Ready to install: Click "Install"

4. **Complete Installation**
   - Wait for installation to complete
   - Check "Launch Mini Mercado" if you want to start immediately
   - Click "Finish"

### Method 2: Portable Version

1. **Download Portable Package**
   - Download the `portable` folder from the release
   - Extract to a folder of your choice (e.g., `C:\Programs\MiniMercado`)

2. **Run the Application**
   - Navigate to the extracted folder
   - Double-click `RUN_MINI_MERCADO.bat` for easy startup
   - OR double-click `salaries_app.exe` directly

3. **Create Shortcut (Optional)**
   - Right-click on `salaries_app.exe`
   - Select "Create shortcut"
   - Move shortcut to Desktop or Start Menu folder

## ⚙️ First Time Setup

### Initial Launch
1. **Start the Application**
   - From Start Menu: "Mini Mercado - Balance Closing System"
   - From Desktop: Double-click the icon
   - Portable: Run from your chosen folder

2. **Create Admin Account**
   - On first run, you'll be prompted to create an admin account
   - Choose a strong username and password
   - This account will have full system access

3. **Configure Settings**
   - Access Settings from the main menu
   - Set your preferred currency (Kwanza recommended)
   - Configure receipt printer if available
   - Adjust display preferences

### Database Initialization
- The application automatically creates a local database
- No additional database software is required
- Database files are stored in the application directory

## 🔧 Troubleshooting Installation

### Common Issues

**"Windows protected your PC" message:**
- Click "More info" → "Run anyway"
- This happens because the app isn't digitally signed yet

**Installation fails with permissions error:**
- Right-click installer → "Run as administrator"
- Ensure you have admin rights on the computer

**Application won't start after installation:**
- Check Windows Defender hasn't quarantined the file
- Add application folder to Defender exclusions
- Verify all files were installed correctly

**Database errors on first run:**
- Ensure application folder has write permissions
- Run application as administrator once
- Check available disk space

### Getting Help

If you encounter issues not covered here:

1. **Check Application Logs**
   - Look for error files in the application directory
   - Note any error messages displayed

2. **System Information**
   - Windows version (Settings → System → About)
   - Available RAM and disk space
   - User account type (Admin/Standard)

3. **Contact Support**
   - Create an issue on GitHub
   - Include error messages and system information
   - Attach log files if available

## 🔄 Updating from Previous Version

### Automatic Update (if available)
- The application will notify you of updates
- Follow the prompt to download and install

### Manual Update
1. Download the new installer
2. Run the installer (it will detect existing installation)
3. Choose "Upgrade" when prompted
4. Your data and settings will be preserved

### Clean Installation
If you prefer a fresh installation:
1. Backup your data (Export from application)
2. Uninstall the old version
3. Install the new version
4. Import your backed-up data

## 📂 File Locations

### Installed Version
- **Application**: `C:\Program Files\Mini Mercado\Balance Closing System\`
- **Database**: Same as application folder
- **Settings**: Stored in application folder

### Portable Version
- **All files**: Your chosen extraction folder
- **Database**: Same folder as executable
- **Settings**: Same folder as executable

## 🛡️ Security Considerations

### Windows Defender
- Add the application folder to exclusions for better performance
- The application is safe but may trigger false positives

### User Permissions
- Admin rights required for installation only
- Application can run with standard user permissions
- Database writes require folder permissions

### Data Security
- All data is stored locally on your computer
- No data is sent to external servers
- Regular backups are recommended

---

**Need more help?** Check the README.md file or create an issue on GitHub.
