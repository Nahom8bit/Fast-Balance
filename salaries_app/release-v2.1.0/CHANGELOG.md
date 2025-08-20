# Changelog - Mini Mercado Balance Closing System

## [2.1.0] - 2025-01-15

### 🐛 Fixed
- **Dashboard Rendering**: Fixed syntax error in chart ternary operator (line 589)
- **Method Resolution**: Resolved undefined `_formatNumber` method errors in dashboard components (lines 680, 699, 765, 803)
- **Code Cleanup**: Removed unused local variable 'color' in tooltip generation (line 696)
- **Memory Optimization**: Removed unused `_hasBeenTouched` field in form validation service
- **Flutter Analyzer**: Resolved all 9 analyzer warnings and errors

### 🔧 Technical Improvements
- Simplified complex chart rendering logic for better maintainability
- Improved code structure and method organization
- Enhanced error handling in chart components
- Optimized memory usage by removing unused declarations

### 📦 Build Changes
- Updated version from 2.0.0+1 to 2.1.0+2
- Updated installer version to 2.1.0
- Cleaned build pipeline for consistent releases

---

## [2.0.0] - 2025-01-14

### ✨ Added
- Auto-update system with GitHub integration
- Kwanza currency support with proper formatting
- Dynamic chart scaling and interactive tooltips
- Cashier management system with role-based access
- Professional dashboard with KPI cards and analytics

### 🎨 Changed
- Complete UI/UX redesign with modern Material Design
- Enhanced database schema for better performance
- Improved chart interactions and visual feedback
- Optimized application startup and loading times

### 🐛 Fixed
- UI overflow issues on smaller screens
- Chart rendering problems with large datasets
- Database migration issues during updates
- Memory leaks in chart components

---

## [1.0.0] - 2025-01-01

### ✨ Initial Release
- Daily balance closing functionality
- SQLite database integration
- User authentication system with admin/cashier roles
- Receipt printing capability with PDF generation
- CSV export functionality for data analysis
- Dashboard with real-time analytics
- Multi-currency support (USD, EUR, AOA)
- Admin panel with comprehensive user management
- Settings screen with customizable options

### 🔐 Security Features
- User authentication with secure password storage
- Role-based access control (Admin/Cashier)
- Input validation and sanitization
- Audit trail for all transactions

### 🖥️ Platform Support
- Cross-platform compatibility (Windows, Linux, macOS)
- Native Windows installer with Inno Setup
- Portable version for standalone usage
- Optimized for Windows 10/11

---

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes or significant new features
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes, backwards compatible

**Format**: `MAJOR.MINOR.PATCH+BUILD`
