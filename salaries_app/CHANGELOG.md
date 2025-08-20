# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2025-01-15

### Fixed
- Flutter analyzer issues resolved (9 total issues)
- Syntax error in dashboard chart ternary operator
- Undefined method '_formatNumber' errors in dashboard
- Removed unused local variables and fields
- Code cleanup and optimization

### Technical Improvements
- Simplified complex chart rendering logic
- Improved code structure and organization
- Enhanced error handling in chart components

## [1.0.0] - 2025-01-XX

### Added
- Initial release of Balancer app
- Daily balance closing functionality
- SQLite database integration
- User authentication system
- Receipt printing capability
- CSV export functionality
- Dashboard with analytics
- Multi-currency support
- Admin panel with user management
- Settings screen with currency selection

### Features
- **Core Functionality**
  - Daily financial closing workflow
  - Real-time discrepancy calculations
  - Cashier role management
  - Receipt generation and printing

- **Dashboard Analytics**
  - KPI cards (Cash, TPA, Expenses, Discrepancies)
  - Sales trend visualization
  - Transaction history table
  - Cashier performance tracking

- **Technical Features**
  - Cross-platform support (Windows, Linux, macOS)
  - Local SQLite database
  - PDF generation for receipts
  - Data export to CSV
  - Auto-update system

### Security
- User authentication with role-based access
- Secure password storage
- Input validation and sanitization

---

## Version History

- **v1.0.0** - Initial release with core functionality
- **v1.1.0** - Added auto-update system and Kwanza currency
- **v1.2.0** - Enhanced dashboard and chart improvements

## Release Process

1. Update version in `lib/update_service.dart`
2. Update version in `pubspec.yaml`
3. Build release: `flutter build windows --release`
4. Create GitHub release with tag (e.g., `v1.1.0`)
5. Upload executable to release
6. Add release notes to this changelog 