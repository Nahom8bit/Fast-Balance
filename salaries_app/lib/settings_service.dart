import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

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
}
