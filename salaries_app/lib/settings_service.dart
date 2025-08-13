import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'language_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _businessNameKey = 'business_name';
  static const String _businessAddressKey = 'business_address';
  static const String _businessPhoneKey = 'business_phone';
  static const String _businessEmailKey = 'business_email';
  static const String _businessWebsiteKey = 'business_website';
  static const String _businessTaxIdKey = 'business_tax_id';
  
  static const String _currencyCodeKey = 'currency_code';
  static const String _currencySymbolKey = 'currency_symbol';
  static const String _decimalPlacesKey = 'decimal_places';
  static const String _taxRateKey = 'tax_rate';
  static const String _defaultOpeningBalanceKey = 'default_opening_balance';
  
  static const String _receiptHeaderKey = 'receipt_header';
  static const String _receiptFooterKey = 'receipt_footer';
  static const String _reportTitleKey = 'report_title';
  static const String _paperSizeKey = 'paper_size';
  static const String _printQualityKey = 'print_quality';
  
  static const String _dateFormatKey = 'date_format';
  static const String _timeFormatKey = 'time_format';
  static const String _timezoneKey = 'timezone';
  static const String _localeKey = 'locale';
  
  static const String _themeKey = 'theme';
  static const String _fontSizeKey = 'font_size';
  static const String _autoSaveIntervalKey = 'auto_save_interval';
  static const String _sessionTimeoutKey = 'session_timeout';
  
  // Print Settings
  static const String _defaultPrinterKey = 'default_printer';
  static const String _printPreviewKey = 'print_preview';
  static const String _printCopiesKey = 'print_copies';
  static const String _paperOrientationKey = 'paper_orientation';
  
  // User Management Settings
  static const String _defaultCashierRoleKey = 'default_cashier_role';
  static const String _passwordPolicyKey = 'password_policy';
  static const String _autoLoginKey = 'auto_login';
  static const String _requirePasswordForClosingKey = 'require_password_for_closing';
  
  // Security Settings
  static const String _auditTrailEnabledKey = 'audit_trail_enabled';
  static const String _sessionLoggingEnabledKey = 'session_logging_enabled';
  static const String _dataEncryptionEnabledKey = 'data_encryption_enabled';
  static const String _auditLogRetentionDaysKey = 'audit_log_retention_days';
  static const String _sessionLogRetentionDaysKey = 'session_log_retention_days';

  // Data Management Settings
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _backupLocationKey = 'backup_location';
  static const String _backupFrequencyKey = 'backup_backup_frequency';
  static const String _dataRetentionPeriodKey = 'data_retention_period';
  static const String _exportFormatKey = 'export_format';
  static const String _backupTimeKey = 'backup_time';

  // Business Intelligence Settings
  static const String _kpiDisplayCustomizationKey = 'kpi_display_customization';
  static const String _chartTypePreferencesKey = 'chart_type_preferences';
  static const String _defaultDateRangeKey = 'default_date_range';
  static const String _alertThresholdConfigKey = 'alert_threshold_config';
  static const String _dashboardRefreshIntervalKey = 'dashboard_refresh_interval';
  static const String _showTrendsEnabledKey = 'show_trends_enabled';
  static const String _performanceMetricsEnabledKey = 'performance_metrics_enabled';

  // Default values
  static const String _defaultBusinessName = 'Mini Mercado';
  static const String _defaultCurrencyCode = 'USD';
  static const String _defaultCurrencySymbol = '\$';
  static const int _defaultDecimalPlaces = 2;
  static const double _defaultTaxRate = 0.0;
  static const double _defaultOpeningBalance = 0.0;
  static const String _defaultReceiptHeader = 'Mini Mercado';
  static const String _defaultReceiptFooter = 'Thank you for your business!';
  static const String _defaultReportTitle = 'Closing Report';
  static const String _defaultPaperSize = '80mm';
  static const String _defaultPrintQuality = 'normal';
  static const String _defaultDateFormat = 'MM/dd/yyyy';
  static const String _defaultTimeFormat = '12-hour';
  static const String _defaultTheme = 'system';
  static const String _defaultFontSize = 'medium';
  static const int _defaultAutoSaveInterval = 30; // seconds
  static const int _defaultSessionTimeout = 30; // minutes
  
  // Print Settings Defaults
  static const String _defaultPrinter = '';
  static const bool _defaultPrintPreview = true;
  static const int _defaultPrintCopies = 1;
  static const String _defaultPaperOrientation = 'portrait';
  
  // User Management Defaults
  static const String _defaultCashierRole = 'cashier';
  static const String _defaultPasswordPolicy = 'medium';
  static const bool _defaultAutoLogin = false;
  static const bool _defaultRequirePasswordForClosing = false;
  
  // Security Settings Defaults
  static const bool _defaultAuditTrailEnabled = false;
  static const bool _defaultSessionLoggingEnabled = false;
  static const bool _defaultDataEncryptionEnabled = false;
  static const int _defaultAuditLogRetentionDays = 90;
  static const int _defaultSessionLogRetentionDays = 30;

  // Data Management Defaults
  static const bool _defaultAutoBackupEnabled = false;
  static const String _defaultBackupLocation = 'Documents/MiniMercado/Backups';
  static const String _defaultBackupFrequency = 'daily';
  static const int _defaultDataRetentionPeriod = 365;
  static const String _defaultExportFormat = 'csv';
  static const String _defaultBackupTime = '02:00';

  // Business Intelligence Defaults
  static const String _defaultKpiDisplayCustomization = 'all';
  static const String _defaultChartTypePreferences = 'line';
  static const String _defaultDateRange = '7d';
  static const String _defaultAlertThresholdConfig = 'medium';
  static const int _defaultDashboardRefreshInterval = 30;
  static const bool _defaultShowTrendsEnabled = true;
  static const bool _defaultPerformanceMetricsEnabled = true;

  // Business Information
  Future<String> getBusinessName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessNameKey) ?? _defaultBusinessName;
  }

  Future<void> setBusinessName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessNameKey, name);
  }

  Future<String> getBusinessAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessAddressKey) ?? '';
  }

  Future<void> setBusinessAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessAddressKey, address);
  }

  Future<String> getBusinessPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessPhoneKey) ?? '';
  }

  Future<void> setBusinessPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessPhoneKey, phone);
  }

  Future<String> getBusinessEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessEmailKey) ?? '';
  }

  Future<void> setBusinessEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessEmailKey, email);
  }

  Future<String> getBusinessWebsite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessWebsiteKey) ?? '';
  }

  Future<void> setBusinessWebsite(String website) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessWebsiteKey, website);
  }

  Future<String> getBusinessTaxId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessTaxIdKey) ?? '';
  }

  Future<void> setBusinessTaxId(String taxId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessTaxIdKey, taxId);
  }

  // Currency & Financial Settings
  Future<String> getCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyCodeKey) ?? _defaultCurrencyCode;
  }

  Future<void> setCurrencyCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodeKey, code);
  }

  Future<String> getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencySymbolKey) ?? _defaultCurrencySymbol;
  }

  Future<void> setCurrencySymbol(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencySymbolKey, symbol);
  }

  Future<int> getDecimalPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_decimalPlacesKey) ?? _defaultDecimalPlaces;
  }

  Future<void> setDecimalPlaces(int places) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_decimalPlacesKey, places);
  }

  Future<double> getTaxRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_taxRateKey) ?? _defaultTaxRate;
  }

  Future<void> setTaxRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_taxRateKey, rate);
  }

  Future<double> getDefaultOpeningBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_defaultOpeningBalanceKey) ?? _defaultOpeningBalance;
  }

  Future<void> setDefaultOpeningBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultOpeningBalanceKey, balance);
  }

  // Receipt & Report Settings
  Future<String> getReceiptHeader() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_receiptHeaderKey) ?? _defaultReceiptHeader;
  }

  Future<void> setReceiptHeader(String header) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_receiptHeaderKey, header);
  }

  Future<String> getReceiptFooter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_receiptFooterKey) ?? _defaultReceiptFooter;
  }

  Future<void> setReceiptFooter(String footer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_receiptFooterKey, footer);
  }

  Future<String> getReportTitle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reportTitleKey) ?? _defaultReportTitle;
  }

  Future<void> setReportTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reportTitleKey, title);
  }

  Future<String> getPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_paperSizeKey) ?? _defaultPaperSize;
  }

  Future<void> setPaperSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paperSizeKey, size);
  }

  Future<String> getPrintQuality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printQualityKey) ?? _defaultPrintQuality;
  }

  Future<void> setPrintQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printQualityKey, quality);
  }

  // Date & Time Settings
  Future<String> getDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateFormatKey) ?? _defaultDateFormat;
  }

  Future<void> setDateFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateFormatKey, format);
  }

  Future<String> getTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeFormatKey) ?? _defaultTimeFormat;
  }

  Future<void> setTimeFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeFormatKey, format);
  }

  Future<String> getTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timezoneKey) ?? 'UTC';
  }

  Future<void> setTimezone(String timezone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timezoneKey, timezone);
  }

  Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'en_US';
  }

  Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
    
    // Update language service
    final languageService = LanguageService();
    await languageService.setLanguage(locale.split('_')[0]);
  }

  // System Preferences
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? _defaultTheme;
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<String> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontSizeKey) ?? _defaultFontSize;
  }

  Future<void> setFontSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, size);
  }

  Future<int> getAutoSaveInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoSaveIntervalKey) ?? _defaultAutoSaveInterval;
  }

  Future<void> setAutoSaveInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoSaveIntervalKey, seconds);
  }

  Future<int> getSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionTimeoutKey) ?? _defaultSessionTimeout;
  }

  Future<void> setSessionTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionTimeoutKey, minutes);
  }

  // Print Settings
  Future<String> getDefaultPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultPrinterKey) ?? _defaultPrinter;
  }

  Future<void> setDefaultPrinter(String printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultPrinterKey, printer);
  }

  Future<bool> getPrintPreview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_printPreviewKey) ?? _defaultPrintPreview;
  }

  Future<void> setPrintPreview(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_printPreviewKey, enabled);
  }

  Future<int> getPrintCopies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_printCopiesKey) ?? _defaultPrintCopies;
  }

  Future<void> setPrintCopies(int copies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_printCopiesKey, copies);
  }

  Future<String> getPaperOrientation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_paperOrientationKey) ?? _defaultPaperOrientation;
  }

  Future<void> setPaperOrientation(String orientation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paperOrientationKey, orientation);
  }

  // User Management Settings
  Future<String> getDefaultCashierRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCashierRoleKey) ?? _defaultCashierRole;
  }

  Future<void> setDefaultCashierRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCashierRoleKey, role);
  }

  Future<String> getPasswordPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordPolicyKey) ?? _defaultPasswordPolicy;
  }

  Future<void> setPasswordPolicy(String policy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordPolicyKey, policy);
  }

  Future<bool> getAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? _defaultAutoLogin;
  }

  Future<void> setAutoLogin(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, enabled);
  }

  Future<bool> getRequirePasswordForClosing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_requirePasswordForClosingKey) ?? _defaultRequirePasswordForClosing;
  }

  Future<void> setRequirePasswordForClosing(bool required) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_requirePasswordForClosingKey, required);
  }

  // Security Settings
  Future<bool> getAuditTrailEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_auditTrailEnabledKey) ?? _defaultAuditTrailEnabled;
  }

  Future<void> setAuditTrailEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_auditTrailEnabledKey, enabled);
  }

  Future<bool> getSessionLoggingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionLoggingEnabledKey) ?? _defaultSessionLoggingEnabled;
  }

  Future<void> setSessionLoggingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionLoggingEnabledKey, enabled);
  }

  Future<bool> getDataEncryptionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataEncryptionEnabledKey) ?? _defaultDataEncryptionEnabled;
  }

  Future<void> setDataEncryptionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataEncryptionEnabledKey, enabled);
  }

  Future<int> getAuditLogRetentionDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_auditLogRetentionDaysKey) ?? _defaultAuditLogRetentionDays;
  }

  Future<void> setAuditLogRetentionDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_auditLogRetentionDaysKey, days);
  }

  Future<int> getSessionLogRetentionDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionLogRetentionDaysKey) ?? _defaultSessionLogRetentionDays;
  }

  Future<void> setSessionLogRetentionDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionLogRetentionDaysKey, days);
  }

  // Data Management Settings
  Future<bool> getAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupEnabledKey) ?? _defaultAutoBackupEnabled;
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);
  }

  Future<String> getBackupLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backupLocationKey) ?? _defaultBackupLocation;
  }

  Future<void> setBackupLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backupLocationKey, location);
  }

  Future<String> getBackupFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backupFrequencyKey) ?? _defaultBackupFrequency;
  }

  Future<void> setBackupFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backupFrequencyKey, frequency);
  }

  Future<int> getDataRetentionPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dataRetentionPeriodKey) ?? _defaultDataRetentionPeriod;
  }

  Future<void> setDataRetentionPeriod(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dataRetentionPeriodKey, days);
  }

  Future<String> getExportFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_exportFormatKey) ?? _defaultExportFormat;
  }

  Future<void> setExportFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exportFormatKey, format);
  }

  Future<String> getBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backupTimeKey) ?? _defaultBackupTime;
  }

  Future<void> setBackupTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backupTimeKey, time);
  }

  // Business Intelligence Settings
  Future<String> getKpiDisplayCustomization() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kpiDisplayCustomizationKey) ?? _defaultKpiDisplayCustomization;
  }

  Future<void> setKpiDisplayCustomization(String customization) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kpiDisplayCustomizationKey, customization);
  }

  Future<String> getChartTypePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chartTypePreferencesKey) ?? _defaultChartTypePreferences;
  }

  Future<void> setChartTypePreferences(String chartType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chartTypePreferencesKey, chartType);
  }

  Future<String> getDefaultDateRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultDateRangeKey) ?? _defaultDateRange;
  }

  Future<void> setDefaultDateRange(String dateRange) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultDateRangeKey, dateRange);
  }

  Future<String> getAlertThresholdConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_alertThresholdConfigKey) ?? _defaultAlertThresholdConfig;
  }

  Future<void> setAlertThresholdConfig(String threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alertThresholdConfigKey, threshold);
  }

  Future<int> getDashboardRefreshInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dashboardRefreshIntervalKey) ?? _defaultDashboardRefreshInterval;
  }

  Future<void> setDashboardRefreshInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dashboardRefreshIntervalKey, seconds);
  }

  Future<bool> getShowTrendsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showTrendsEnabledKey) ?? _defaultShowTrendsEnabled;
  }

  Future<void> setShowTrendsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTrendsEnabledKey, enabled);
  }

  Future<bool> getPerformanceMetricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_performanceMetricsEnabledKey) ?? _defaultPerformanceMetricsEnabled;
  }

  Future<void> setPerformanceMetricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_performanceMetricsEnabledKey, enabled);
  }

  // Utility methods
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'businessName': await getBusinessName(),
      'businessAddress': await getBusinessAddress(),
      'businessPhone': await getBusinessPhone(),
      'businessEmail': await getBusinessEmail(),
      'businessWebsite': await getBusinessWebsite(),
      'businessTaxId': await getBusinessTaxId(),
      'currencyCode': await getCurrencyCode(),
      'currencySymbol': await getCurrencySymbol(),
      'decimalPlaces': await getDecimalPlaces(),
      'taxRate': await getTaxRate(),
      'defaultOpeningBalance': await getDefaultOpeningBalance(),
      'receiptHeader': await getReceiptHeader(),
      'receiptFooter': await getReceiptFooter(),
      'reportTitle': await getReportTitle(),
      'paperSize': await getPaperSize(),
      'printQuality': await getPrintQuality(),
      'dateFormat': await getDateFormat(),
      'timeFormat': await getTimeFormat(),
      'timezone': await getTimezone(),
      'locale': await getLocale(),
      'theme': await getTheme(),
      'fontSize': await getFontSize(),
      'autoSaveInterval': await getAutoSaveInterval(),
      'sessionTimeout': await getSessionTimeout(),
      'defaultPrinter': await getDefaultPrinter(),
      'printPreview': await getPrintPreview(),
      'printCopies': await getPrintCopies(),
      'paperOrientation': await getPaperOrientation(),
              'auditTrailEnabled': await getAuditTrailEnabled(),
        'sessionLoggingEnabled': await getSessionLoggingEnabled(),
        'dataEncryptionEnabled': await getDataEncryptionEnabled(),
        'auditLogRetentionDays': await getAuditLogRetentionDays(),
        'sessionLogRetentionDays': await getSessionLogRetentionDays(),
        'autoBackupEnabled': await getAutoBackupEnabled(),
        'backupLocation': await getBackupLocation(),
        'backupFrequency': await getBackupFrequency(),
        'dataRetentionPeriod': await getDataRetentionPeriod(),
        'exportFormat': await getExportFormat(),
        'backupTime': await getBackupTime(),
        'kpiDisplayCustomization': await getKpiDisplayCustomization(),
        'chartTypePreferences': await getChartTypePreferences(),
        'defaultDateRange': await getDefaultDateRange(),
        'alertThresholdConfig': await getAlertThresholdConfig(),
        'dashboardRefreshInterval': await getDashboardRefreshInterval(),
        'showTrendsEnabled': await getShowTrendsEnabled(),
        'performanceMetricsEnabled': await getPerformanceMetricsEnabled(),
      };
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Currency options
  static const List<Map<String, String>> currencyOptions = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
  ];

  // Paper size options
  static const List<String> paperSizeOptions = [
    '80mm',
    'A4',
    'Letter',
    'Legal',
  ];

  // Print quality options
  static const List<String> printQualityOptions = [
    'draft',
    'normal',
    'high',
  ];

  // Date format options
  static const List<Map<String, String>> dateFormatOptions = [
    {'value': 'MM/dd/yyyy', 'label': 'MM/DD/YYYY'},
    {'value': 'dd/MM/yyyy', 'label': 'DD/MM/YYYY'},
    {'value': 'yyyy-MM-dd', 'label': 'YYYY-MM-DD'},
    {'value': 'MM-dd-yyyy', 'label': 'MM-DD-YYYY'},
  ];

  // Time format options
  static const List<Map<String, String>> timeFormatOptions = [
    {'value': '12-hour', 'label': '12-Hour (AM/PM)'},
    {'value': '24-hour', 'label': '24-Hour'},
  ];

  // Theme options
  static const List<Map<String, String>> themeOptions = [
    {'value': 'light', 'label': 'Light'},
    {'value': 'dark', 'label': 'Dark'},
    {'value': 'system', 'label': 'System'},
  ];

  // Font size options
  static const List<Map<String, String>> fontSizeOptions = [
    {'value': 'small', 'label': 'Small'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'large', 'label': 'Large'},
  ];

  // User role options
  static const List<Map<String, String>> userRoleOptions = [
    {'value': 'cashier', 'label': 'Cashier'},
    {'value': 'supervisor', 'label': 'Supervisor'},
    {'value': 'manager', 'label': 'Manager'},
    {'value': 'admin', 'label': 'Administrator'},
  ];

  // Password policy options
  static const List<Map<String, String>> passwordPolicyOptions = [
    {'value': 'low', 'label': 'Low (4+ characters)'},
    {'value': 'medium', 'label': 'Medium (6+ characters, letters & numbers)'},
    {'value': 'high', 'label': 'High (8+ characters, mixed case, symbols)'},
    {'value': 'strict', 'label': 'Strict (10+ characters, complex requirements)'},
  ];

  // Print settings options
  static const List<Map<String, String>> paperOrientationOptions = [
    {'value': 'portrait', 'label': 'Portrait'},
    {'value': 'landscape', 'label': 'Landscape'},
  ];

  static const List<Map<String, String>> printCopiesOptions = [
    {'value': '1', 'label': '1 Copy'},
    {'value': '2', 'label': '2 Copies'},
    {'value': '3', 'label': '3 Copies'},
    {'value': '4', 'label': '4 Copies'},
    {'value': '5', 'label': '5 Copies'},
  ];

  // Security settings options
  static const List<Map<String, String>> auditLogRetentionOptions = [
    {'value': '30', 'label': '30 Days'},
    {'value': '60', 'label': '60 Days'},
    {'value': '90', 'label': '90 Days'},
    {'value': '180', 'label': '180 Days'},
    {'value': '365', 'label': '1 Year'},
  ];

  static const List<Map<String, String>> sessionLogRetentionOptions = [
    {'value': '7', 'label': '7 Days'},
    {'value': '15', 'label': '15 Days'},
    {'value': '30', 'label': '30 Days'},
    {'value': '60', 'label': '60 Days'},
    {'value': '90', 'label': '90 Days'},
  ];

  // Data Management options
  static const List<Map<String, String>> backupFrequencyOptions = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
  ];

  static const List<Map<String, String>> dataRetentionOptions = [
    {'value': '30', 'label': '30 Days'},
    {'value': '90', 'label': '90 Days'},
    {'value': '180', 'label': '180 Days'},
    {'value': '365', 'label': '1 Year'},
    {'value': '730', 'label': '2 Years'},
    {'value': '1095', 'label': '3 Years'},
  ];

  static const List<Map<String, String>> exportFormatOptions = [
    {'value': 'csv', 'label': 'CSV'},
    {'value': 'excel', 'label': 'Excel'},
    {'value': 'pdf', 'label': 'PDF'},
    {'value': 'json', 'label': 'JSON'},
  ];

  // Business Intelligence options
  static const List<Map<String, String>> kpiDisplayOptions = [
    {'value': 'all', 'label': 'All KPIs'},
    {'value': 'sales', 'label': 'Sales Only'},
    {'value': 'expenses', 'label': 'Expenses Only'},
    {'value': 'profit', 'label': 'Profit Only'},
    {'value': 'custom', 'label': 'Custom Selection'},
  ];

  static const List<Map<String, String>> chartTypeOptions = [
    {'value': 'line', 'label': 'Line Chart'},
    {'value': 'bar', 'label': 'Bar Chart'},
    {'value': 'pie', 'label': 'Pie Chart'},
    {'value': 'area', 'label': 'Area Chart'},
    {'value': 'column', 'label': 'Column Chart'},
  ];

  static const List<Map<String, String>> dateRangeOptions = [
    {'value': '1d', 'label': 'Today'},
    {'value': '7d', 'label': 'Last 7 Days'},
    {'value': '30d', 'label': 'Last 30 Days'},
    {'value': '90d', 'label': 'Last 90 Days'},
    {'value': '1y', 'label': 'Last Year'},
    {'value': 'custom', 'label': 'Custom Range'},
  ];

  static const List<Map<String, String>> alertThresholdOptions = [
    {'value': 'low', 'label': 'Low Sensitivity'},
    {'value': 'medium', 'label': 'Medium Sensitivity'},
    {'value': 'high', 'label': 'High Sensitivity'},
    {'value': 'custom', 'label': 'Custom Thresholds'},
  ];

  static const List<Map<String, String>> refreshIntervalOptions = [
    {'value': '15', 'label': '15 Seconds'},
    {'value': '30', 'label': '30 Seconds'},
    {'value': '60', 'label': '1 Minute'},
    {'value': '300', 'label': '5 Minutes'},
    {'value': '600', 'label': '10 Minutes'},
  ];
}
