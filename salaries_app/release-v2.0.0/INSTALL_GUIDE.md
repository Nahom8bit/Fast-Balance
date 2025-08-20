# Installation Guide - Mini Mercado Balance Closing System v2.0.0

## 📋 Pre-Installation Requirements

### System Requirements
- **OS**: Windows 10 (version 1903 or later) or Windows 11
- **Architecture**: 64-bit (x64)
- **RAM**: Minimum 4 GB, Recommended 8 GB
- **Storage**: 200 MB free space
- **Display**: 1366x768 minimum resolution

### Prerequisites
- .NET Framework 4.7.2 or higher (usually pre-installed on Windows 10/11)
- Administrator privileges for installation
- Internet connection for initial setup (optional)

## 🚀 Installation Methods

### Method 1: Installer (Recommended)

#### Step 1: Download
- Download `MiniMercadoBalanceSetup.exe` from the release

#### Step 2: Run Installer
1. Right-click on `MiniMercadoBalanceSetup.exe`
2. Select "Run as administrator"
3. If Windows Defender SmartScreen appears, click "More info" then "Run anyway"

#### Step 3: Installation Wizard
1. **Welcome Screen**: Click "Next"
2. **License Agreement**: Accept the license terms
3. **Installation Location**: 
   - Default: `C:\Program Files\Mini Mercado Balance`
   - Or choose custom location
4. **Start Menu Folder**: Accept default or customize
5. **Additional Tasks**: 
   - ✅ Create desktop icon (recommended)
   - ✅ Create Quick Launch icon
6. **Ready to Install**: Review settings and click "Install"
7. **Completing Setup**: Choose to launch immediately

#### Step 4: First Launch
1. Application will start automatically
2. Default login credentials:
   - **Username**: `admin`
   - **Password**: `madebynahom@2025`
3. **Important**: Change the default password immediately

### Method 2: Portable Version

#### Step 1: Extract
1. Download the portable version
2. Extract all files to desired location (e.g., `C:\MiniMercado\`)
3. Ensure the folder has write permissions

#### Step 2: Run Application
1. Navigate to the extracted folder
2. Double-click `salaries_app.exe`
3. Application will create necessary data files in the same folder

## ⚙️ Initial Configuration

### First-Time Setup Wizard

#### 1. Change Default Password
```
Settings > User Management > Change Password
```

#### 2. Configure Business Information
```
Settings > Business Information:
- Business Name: Your business name
- Address: Full business address
- Phone: Contact phone number
- Email: Business email
- Website: Business website (optional)
- Tax ID: Business registration/tax number
```

#### 3. Set Currency and Regional Settings
```
Settings > Currency & Financial:
- Currency: Select your local currency
- Currency Symbol: Will auto-populate
- Decimal Places: Usually 2 for most currencies
- Tax Rate: Your local tax rate percentage
```

#### 4. Configure Receipt Settings
```
Settings > Receipt & Report:
- Receipt Header: Business name or custom header
- Receipt Footer: Thank you message or terms
- Report Title: "Daily Closing Report" or custom
- Paper Size: A4 (recommended) or Letter
- Print Quality: High (for professional receipts)
```

#### 5. Set Up Users (Optional)
```
Admin Panel > User Management:
- Add cashier accounts if needed
- Set appropriate permissions
- Configure password policies
```

## 🔧 Advanced Configuration

### Database Location
- **Installer**: `%APPDATA%\Mini Mercado\`
- **Portable**: Same folder as executable

### Backup Configuration
```
Settings > Data Management:
- Enable Auto Backup: ✅
- Backup Location: Choose secure location
- Backup Frequency: Daily (recommended)
- Backup Time: Off-hours (e.g., 2:00 AM)
```

### Print Setup
```
Settings > Print Settings:
- Default Printer: Select your receipt printer
- Print Preview: Enable for first-time setup
- Paper Orientation: Portrait (recommended)
```

## 🛠️ Troubleshooting

### Installation Issues

#### "Windows protected your PC" message
1. Click "More info"
2. Click "Run anyway"
3. This is normal for new applications

#### Installation fails with permissions error
1. Run installer as Administrator
2. Temporarily disable antivirus if necessary
3. Ensure sufficient disk space

#### Application won't start
1. Verify .NET Framework 4.7.2+ is installed
2. Run as Administrator once
3. Check Windows Event Viewer for error details

### Runtime Issues

#### Database errors
1. Ensure write permissions in application folder
2. Check available disk space
3. Restart application as Administrator

#### Printing issues
1. Verify printer is installed and working
2. Check printer permissions
3. Try Print Preview first
4. Update printer drivers

#### Performance issues
1. Close unnecessary applications
2. Increase virtual memory if needed
3. Run disk cleanup
4. Check for Windows updates

## 📁 File Structure

### Installed Version
```
C:\Program Files\Mini Mercado Balance\
├── salaries_app.exe          # Main application
├── flutter_windows.dll       # Flutter runtime
├── pdfium.dll                # PDF generation
├── printing_plugin.dll       # Print functionality
├── url_launcher_windows_plugin.dll
└── data\                     # Application assets
    └── flutter_assets\
```

### Data Files (User Folder)
```
%APPDATA%\Mini Mercado\
├── BalanceClosing.db         # Main database
├── settings.json             # Application settings
├── backups\                  # Automatic backups
└── exports\                  # CSV/PDF exports
```

## 🔒 Security Considerations

### Data Protection
- Database is encrypted using SQLite encryption
- User passwords are hashed using industry standards
- Backup files maintain encryption

### Network Security
- Application runs locally (no internet required)
- No data transmitted to external servers
- All data remains on your local network

### Access Control
- Role-based user management
- Session timeouts for security
- Audit trail for all transactions

## 🔄 Updates and Maintenance

### Checking for Updates
1. Help > Check for Updates
2. Or download latest version from GitHub releases

### Backup Before Updates
1. Settings > Data Management > Manual Backup
2. Export important data to CSV
3. Note current settings for reconfiguration

### Clean Installation
If needed, completely remove and reinstall:
1. Uninstall via Windows Programs & Features
2. Delete user data folder (if desired)
3. Install new version
4. Restore backup if available

## 📞 Support

### Getting Help
- **Documentation**: Built-in help system
- **GitHub Issues**: Report bugs or request features
- **Email Support**: Contact for business inquiries

### Before Contacting Support
1. Check this installation guide
2. Review troubleshooting section
3. Note exact error messages
4. Document steps to reproduce issues

---

## ✅ Installation Checklist

- [ ] System meets minimum requirements
- [ ] Downloaded correct version (64-bit)
- [ ] Run installer as Administrator
- [ ] Application launches successfully
- [ ] Default password changed
- [ ] Business information configured
- [ ] Currency settings configured
- [ ] Receipt settings configured
- [ ] Backup location set
- [ ] Test print functionality
- [ ] User accounts created (if needed)

**Installation Complete!** Your Mini Mercado Balance Closing System is ready to use.
