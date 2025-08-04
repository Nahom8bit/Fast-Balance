# Change Log

**Date:** 2024-07-25
**Description:** Initial project setup.

**Date:** 2024-12-19
**File:** setup.iss, scripts/build_installer.bat, scripts/create_installer.bat, scripts/build_and_install.bat, INSTALLER_README.md
**Function:** Windows Installer Creation
**Description:** Created complete Windows installer package using Inno Setup with automated build scripts and comprehensive documentation. The installer includes modern UI, proper Windows integration, desktop shortcuts, and uninstall support. Added one-command build and installer creation process.

**Date:** 2024-12-19
**File:** setup.iss, scripts/build_installer.bat, scripts/create_installer.bat
**Function:** Installer Path Fixes
**Description:** Fixed installer configuration to use correct executable name (salaries_app.exe) and build path (build\windows\x64\runner\Release\). Successfully created installer: installer\MiniMercadoBalanceSetup.exe (12.3 MB).

**Date:** 2025-06-24
**File:** database_helper.dart, record_detail_screen.dart, admin_panel.dart, main.dart
**Function:** Enhanced Record Details and Admin Panel
**Description:** 
- Added expenses table to store individual expense entries with description and amount
- Updated record detail screen to display cashier name and individual expense list
- Modified admin panel to show records in format "Cashier's name : DD/MM/YYYY" instead of "Record ID: X"
- Updated database schema to version 5 with proper migration support
- Enhanced data storage to preserve individual expense details for better record keeping

**Date:** 2025-06-24
**File:** main.dart
**Function:** Auto-Clear Form Fields
**Description:** 
- Added _clearAllFields() method to reset all input controllers and state variables
- Updated _closeBalance() to automatically clear all form fields after successful save
- Enhanced success message to inform user that fields have been cleared for next cashier
- Improved user experience by eliminating manual field clearing between cashier shifts

**Date:** 2025-06-24
**File:** main.dart, receipt_printer.dart
**Function:** Print Popup Workflow
**Description:** 
- Added _showPrintDialog() method to display print options after record save
- Implemented workflow: Save Record → Print Popup → Clear Fields
- Enhanced receipt printer to include cashier name and better formatting
- Added error handling for print failures with user feedback
- Non-dismissible dialog ensures cashier makes a choice before proceeding

**Date:** 2025-06-24
**File:** theme_service.dart, main.dart, settings_screen.dart
**Function:** Dark Theme Implementation
**Description:** 
- Created ThemeService class to manage light and dark themes
- Added comprehensive dark theme with proper colors and styling
- Updated main app to support dynamic theme switching
- Added theme selection dropdown in settings screen (Light/Dark/System)
- Implemented theme persistence using SharedPreferences
- Added user feedback when theme is changed
- Improved theme consistency with better color balance
- Fixed theme switching responsiveness using ThemeNotifier
- Enhanced dark theme to be less harsh and more professional

**Date:** 2025-06-24
**File:** theme_service.dart
**Function:** Contrast Improvements
**Description:** 
- Fixed text contrast issues in dark theme for better readability
- Improved input field label colors (white70 for dark, black87 for light)
- Enhanced hint text colors (white54 for dark, black54 for light)
- Added floating label styles with teal accent color
- Improved list tile text contrast with proper title and subtitle styles
- Enhanced data table theme for better table readability
- Added chip theme with proper contrast for status indicators
- Fixed label text styles for all UI elements

**Date:** 2025-06-24
**File:** dashboard_screen.dart
**Function:** Dashboard Theme Consistency
**Description:** 
- Replaced all hardcoded colors with theme-based colors throughout dashboard
- Fixed header background and text colors to use theme colors
- Updated KPI cards to use theme text colors for better contrast
- Improved chart labels and axis text to use theme colors
- Fixed discrepancies section text colors for better readability
- Updated transaction table headers and data to use theme colors
- Enhanced date picker and dropdown styling with theme colors
- Improved search field styling with proper theme integration 