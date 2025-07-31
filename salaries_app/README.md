# 💰 Mini Mercado - Daily Balance Closing System

A professional Flutter application for managing daily financial closings with advanced features and Kwanza currency support.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

## 🚀 Features

### 💼 **Core Functionality**
- ✅ **Daily Balance Closing**: Complete financial closing workflow
- ✅ **Real-time Calculations**: Instant discrepancy detection
- ✅ **Multi-currency Support**: Kwanza (Kz), USD, EUR, L.K.R
- ✅ **Cashier Management**: Role-based access with user accounts
- ✅ **Receipt Printing**: POS thermal printer support (80mm)

### 📊 **Advanced Dashboard**
- ✅ **KPI Cards**: Cash, TPA, Expenses, Discrepancies
- ✅ **Sales Trend Charts**: Dynamic visualization with real data
- ✅ **Transaction Details**: Comprehensive transaction table
- ✅ **Discrepancies by Cashier**: Performance tracking
- ✅ **Date Range Filtering**: Flexible data analysis

### 🔧 **Technical Features**
- ✅ **SQLite Database**: Local data persistence
- ✅ **Auto-update System**: GitHub release integration
- ✅ **PDF Generation**: Professional receipt printing
- ✅ **CSV Export**: Data export functionality
- ✅ **Cross-platform**: Windows, Linux, macOS support

## 📱 Screenshots

### Main Dashboard
![Dashboard](https://via.placeholder.com/800x400/1E3A8A/FFFFFF?text=Mini+Mercado+Dashboard)

### Closing Form
![Closing Form](https://via.placeholder.com/800x400/10B981/FFFFFF?text=Daily+Closing+Form)

## 🛠️ Installation

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Windows 10/11 (for Windows build)
- Git

### Quick Start
```bash
# Clone the repository
git clone https://github.com/Nahom8bit/Fast-Balance.git

# Navigate to the app directory
cd Fast-Balance/salaries_app

# Install dependencies
flutter pub get

# Run the application
flutter run -d windows
```

### Build for Production
```bash
# Build Windows executable
flutter build windows --release

# The executable will be in:
# build/windows/x64/runner/Release/salaries_app.exe
```

## 🔐 Default Login Credentials

- **Username**: `admin`
- **Password**: `madebynahom@2025`

## 💰 Currency Support

The app supports multiple currencies:
- **Kwanza (Kz)** - Default currency
- **USD** - US Dollar
- **EUR** - Euro
- **L.K.R** - Legacy currency

Change currency in Settings → Currency dropdown.

## 🔄 Auto-Update System

The app automatically checks for updates from GitHub releases:

### For Users:
- Updates check automatically when app starts
- Manual check available in Settings
- Beautiful update dialog with release notes
- Direct download from GitHub releases

### For Developers:
1. Update version in `lib/update_service.dart`
2. Create GitHub release with tag (e.g., `v1.0.1`)
3. Upload the new `.exe` file
4. Add release notes

## 📊 Database Schema

### Closing Records Table
```sql
CREATE TABLE closing_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  cash REAL NOT NULL,
  tpa REAL NOT NULL,
  expenses REAL NOT NULL,
  opening_balance REAL NOT NULL,
  sales REAL NOT NULL,
  discrepancy REAL NOT NULL,
  cashier TEXT NOT NULL,
  created_at TEXT NOT NULL
);
```

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  created_at TEXT NOT NULL
);
```

## 🎯 Key Features Explained

### 1. **Daily Closing Process**
1. Enter **Cash** (closing cash on hand)
2. Add **TPA** (card/mobile payments)
3. Add **Expenses** (daily expenses)
4. Enter **Opening Balance** (morning cash)
5. Enter **Sales** (system sales)
6. View **Discrepancy** (automatic calculation)

### 2. **Discrepancy Logic**
- **Positive Discrepancy**: Sales > Calculated Total
  - Indicates unrecorded expenses or missing money
- **Negative Discrepancy**: Sales < Calculated Total
  - Indicates credit payments or system errors

### 3. **Dashboard Analytics**
- **Real-time KPIs**: Live calculations from database
- **Sales Trends**: Visual chart with Cash vs TPA
- **Cashier Performance**: Discrepancy tracking by cashier
- **Transaction History**: Detailed record table

## 🔧 Configuration

### Update GitHub Repository
Edit `lib/update_service.dart`:
```dart
static const String _githubApiUrl = 'https://api.github.com/repos/Nahom8bit/Fast-Balance/releases/latest';
```

### Change Default Currency
Edit `lib/currency_formatter.dart`:
```dart
static String _currencySymbol = 'Kz'; // Change default currency
```

### Modify Update Check Frequency
Edit `lib/update_service.dart`:
```dart
// Check once per day (24 hours)
return difference.inHours >= 24;

// Check once per week
return difference.inHours >= 168;
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

## 🐛 Troubleshooting

### Common Issues

#### App Won't Start
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d windows
```

#### Database Issues
- Delete the database file and restart
- Check file permissions in app directory

#### Update System Not Working
1. Verify GitHub repository URL
2. Check internet connection
3. Ensure GitHub release is published (not draft)

#### Receipt Printing Issues
- Check printer connection
- Verify 80mm paper size
- Test with different PDF viewers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Nahom8bit**
- GitHub: [@Nahom8bit](https://github.com/Nahom8bit)
- Project: [Fast-Balance](https://github.com/Nahom8bit/Fast-Balance)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- SQLite for reliable local database
- FL Chart for beautiful data visualization
- All contributors and testers

---

**Made with ❤️ for Mini Mercado**

*For support, create an issue on GitHub or contact the developer.*
