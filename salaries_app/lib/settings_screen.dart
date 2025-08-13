import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';
import 'language_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final LanguageService _languageService = LanguageService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  late TextEditingController _businessNameController;
  late TextEditingController _businessAddressController;
  late TextEditingController _businessPhoneController;
  late TextEditingController _businessEmailController;
  late TextEditingController _businessWebsiteController;
  late TextEditingController _businessTaxIdController;
  late TextEditingController _taxRateController;
  late TextEditingController _defaultOpeningBalanceController;
  late TextEditingController _receiptHeaderController;
  late TextEditingController _receiptFooterController;
  late TextEditingController _reportTitleController;
  late TextEditingController _autoSaveIntervalController;
  late TextEditingController _sessionTimeoutController;
  late TextEditingController _backupLocationController;
  late TextEditingController _backupTimeController;

  // Dropdown values
  String _selectedCurrency = 'USD';
  String _selectedCurrencySymbol = '\$';
  int _selectedDecimalPlaces = 2;
  String _selectedPaperSize = '80mm';
  String _selectedPrintQuality = 'normal';
  String _selectedDateFormat = 'MM/dd/yyyy';
  String _selectedTimeFormat = '12-hour';
  String _selectedTheme = 'system';
  String _selectedFontSize = 'medium';
  
  // Print Settings values
  String _selectedDefaultPrinter = '';
  bool _printPreview = true;
  int _selectedPrintCopies = 1;
  String _selectedPaperOrientation = 'portrait';
  
  // User Management values
  String _selectedDefaultCashierRole = 'cashier';
  String _selectedPasswordPolicy = 'medium';
  bool _autoLogin = false;
  bool _requirePasswordForClosing = false;

  // Security Settings values
  bool _auditTrailEnabled = false;
  bool _sessionLoggingEnabled = false;
  bool _dataEncryptionEnabled = false;
  int _auditLogRetentionDays = 90;
  int _sessionLogRetentionDays = 30;

  // Data Management values
  bool _autoBackupEnabled = false;
  String _backupLocation = 'Documents/MiniMercado/Backups';
  String _backupFrequency = 'daily';
  int _dataRetentionPeriod = 365;
  String _exportFormat = 'csv';
  String _backupTime = '02:00';

  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSettings();
    
    // Listen to language changes
    _languageService.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    setState(() {
      // Rebuild UI when language changes
    });
  }

  void _initializeControllers() {
    _businessNameController = TextEditingController();
    _businessAddressController = TextEditingController();
    _businessPhoneController = TextEditingController();
    _businessEmailController = TextEditingController();
    _businessWebsiteController = TextEditingController();
    _businessTaxIdController = TextEditingController();
    _taxRateController = TextEditingController();
    _defaultOpeningBalanceController = TextEditingController();
    _receiptHeaderController = TextEditingController();
    _receiptFooterController = TextEditingController();
    _backupLocationController = TextEditingController();
    _backupTimeController = TextEditingController();
    _reportTitleController = TextEditingController();
    _autoSaveIntervalController = TextEditingController();
    _sessionTimeoutController = TextEditingController();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getAllSettings();
      
      setState(() {
        _businessNameController.text = settings['businessName'] ?? '';
        _businessAddressController.text = settings['businessAddress'] ?? '';
        _businessPhoneController.text = settings['businessPhone'] ?? '';
        _businessEmailController.text = settings['businessEmail'] ?? '';
        _businessWebsiteController.text = settings['businessWebsite'] ?? '';
        _businessTaxIdController.text = settings['businessTaxId'] ?? '';
        _taxRateController.text = (settings['taxRate'] ?? 0.0).toString();
        _defaultOpeningBalanceController.text = (settings['defaultOpeningBalance'] ?? 0.0).toString();
        _receiptHeaderController.text = settings['receiptHeader'] ?? '';
        _receiptFooterController.text = settings['receiptFooter'] ?? '';
        _reportTitleController.text = settings['reportTitle'] ?? '';
        _autoSaveIntervalController.text = (settings['autoSaveInterval'] ?? 30).toString();
        _sessionTimeoutController.text = (settings['sessionTimeout'] ?? 30).toString();

        _selectedCurrency = settings['currencyCode'] ?? 'USD';
        _selectedCurrencySymbol = settings['currencySymbol'] ?? '\$';
        _selectedDecimalPlaces = settings['decimalPlaces'] ?? 2;
        _selectedPaperSize = settings['paperSize'] ?? '80mm';
        _selectedPrintQuality = settings['printQuality'] ?? 'normal';
        _selectedDateFormat = settings['dateFormat'] ?? 'MM/dd/yyyy';
        _selectedTimeFormat = settings['timeFormat'] ?? '12-hour';
        _selectedTheme = settings['theme'] ?? 'system';
        _selectedFontSize = settings['fontSize'] ?? 'medium';

        // Print Settings
        _selectedDefaultPrinter = settings['defaultPrinter'] ?? '';
        _printPreview = settings['printPreview'] ?? true;
        _selectedPrintCopies = settings['printCopies'] ?? 1;
        _selectedPaperOrientation = settings['paperOrientation'] ?? 'portrait';

        // User Management settings
        _selectedDefaultCashierRole = settings['defaultCashierRole'] ?? 'cashier';
        _selectedPasswordPolicy = settings['passwordPolicy'] ?? 'medium';
        _autoLogin = settings['autoLogin'] ?? false;
        _requirePasswordForClosing = settings['requirePasswordForClosing'] ?? false;

        // Security Settings
        _auditTrailEnabled = settings['auditTrailEnabled'] ?? false;
        _sessionLoggingEnabled = settings['sessionLoggingEnabled'] ?? false;
        _dataEncryptionEnabled = settings['dataEncryptionEnabled'] ?? false;
        _auditLogRetentionDays = settings['auditLogRetentionDays'] ?? 90;
        _sessionLogRetentionDays = settings['sessionLogRetentionDays'] ?? 30;

        // Data Management
        _autoBackupEnabled = settings['autoBackupEnabled'] ?? false;
        _backupLocation = settings['backupLocation'] ?? 'Documents/MiniMercado/Backups';
        _backupFrequency = settings['backupFrequency'] ?? 'daily';
        _dataRetentionPeriod = settings['dataRetentionPeriod'] ?? 365;
        _exportFormat = settings['exportFormat'] ?? 'csv';
        _backupTime = settings['backupTime'] ?? '02:00';

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Save all settings
      await _settingsService.setBusinessName(_businessNameController.text);
      await _settingsService.setBusinessAddress(_businessAddressController.text);
      await _settingsService.setBusinessPhone(_businessPhoneController.text);
      await _settingsService.setBusinessEmail(_businessEmailController.text);
      await _settingsService.setBusinessWebsite(_businessWebsiteController.text);
      await _settingsService.setBusinessTaxId(_businessTaxIdController.text);
      await _settingsService.setTaxRate(double.tryParse(_taxRateController.text) ?? 0.0);
      await _settingsService.setDefaultOpeningBalance(double.tryParse(_defaultOpeningBalanceController.text) ?? 0.0);
      await _settingsService.setReceiptHeader(_receiptHeaderController.text);
      await _settingsService.setReceiptFooter(_receiptFooterController.text);
      await _settingsService.setReportTitle(_reportTitleController.text);
      await _settingsService.setAutoSaveInterval(int.tryParse(_autoSaveIntervalController.text) ?? 30);
      await _settingsService.setSessionTimeout(int.tryParse(_sessionTimeoutController.text) ?? 30);

      await _settingsService.setCurrencyCode(_selectedCurrency);
      await _settingsService.setCurrencySymbol(_selectedCurrencySymbol);
      await _settingsService.setDecimalPlaces(_selectedDecimalPlaces);
      await _settingsService.setPaperSize(_selectedPaperSize);
      await _settingsService.setPrintQuality(_selectedPrintQuality);
      await _settingsService.setDateFormat(_selectedDateFormat);
      await _settingsService.setTimeFormat(_selectedTimeFormat);
      await _settingsService.setTheme(_selectedTheme);
      await _settingsService.setFontSize(_selectedFontSize);

      // Save Print Settings
      await _settingsService.setDefaultPrinter(_selectedDefaultPrinter);
      await _settingsService.setPrintPreview(_printPreview);
      await _settingsService.setPrintCopies(_selectedPrintCopies);
      await _settingsService.setPaperOrientation(_selectedPaperOrientation);

      // Save User Management settings
      await _settingsService.setDefaultCashierRole(_selectedDefaultCashierRole);
      await _settingsService.setPasswordPolicy(_selectedPasswordPolicy);
      await _settingsService.setAutoLogin(_autoLogin);
      await _settingsService.setRequirePasswordForClosing(_requirePasswordForClosing);

              // Save Security Settings
        await _settingsService.setAuditTrailEnabled(_auditTrailEnabled);
        await _settingsService.setSessionLoggingEnabled(_sessionLoggingEnabled);
        await _settingsService.setDataEncryptionEnabled(_dataEncryptionEnabled);
        await _settingsService.setAuditLogRetentionDays(_auditLogRetentionDays);
        await _settingsService.setSessionLogRetentionDays(_sessionLogRetentionDays);

        // Save Data Management Settings
        await _settingsService.setAutoBackupEnabled(_autoBackupEnabled);
        await _settingsService.setBackupLocation(_backupLocation);
        await _settingsService.setBackupFrequency(_backupFrequency);
        await _settingsService.setDataRetentionPeriod(_dataRetentionPeriod);
        await _settingsService.setExportFormat(_exportFormat);
        await _settingsService.setBackupTime(_backupTime);

        setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      _showSuccessSnackBar('settings_saved');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('error_saving$e');
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_languageService.getString(message)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_languageService.getString(message)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _settingsService.resetToDefaults();
        await _loadSettings();
              _showSuccessSnackBar('settings_reset');
    } catch (e) {
      _showErrorSnackBar('error_resetting$e');
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.getString('settings')),
        actions: [
                      if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveSettings,
                child: Text(_languageService.getString('save')),
              ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  _resetToDefaults();
                  break;
                case 'export':
                  // TODO: Implement export settings
                  break;
                case 'import':
                  // TODO: Implement import settings
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Text(_languageService.getString('reset_to_defaults')),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Settings'),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Text('Import Settings'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessInformationSection(),
                    const SizedBox(height: 24),
                    _buildCurrencySettingsSection(),
                    const SizedBox(height: 24),
                    _buildReceiptSettingsSection(),
                    const SizedBox(height: 24),
                                         _buildSystemSettingsSection(),
                     const SizedBox(height: 24),
                     _buildUserManagementSection(),
                     const SizedBox(height: 24),
                                         _buildPrintSettingsSection(),
                    const SizedBox(height: 24),
                                            _buildSecuritySettingsSection(),
                        const SizedBox(height: 24),
                        _buildDataManagementSection(),
                        const SizedBox(height: 24),
                        _buildLanguageSettingsSection(),
                     const SizedBox(height: 24),
                     _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBusinessInformationSection() {
    return _buildSection(
      title: _languageService.getString('business_information'),
      icon: Icons.business,
      children: [
        _buildTextField(
          controller: _businessNameController,
          label: 'Business Name',
          hint: 'Enter your business name',
          validator: (value) => value?.isEmpty == true ? 'Business name is required' : null,
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _businessAddressController,
          label: 'Business Address',
          hint: 'Enter your business address',
          maxLines: 2,
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _businessPhoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _businessEmailController,
          label: 'Email Address',
          hint: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isNotEmpty == true && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _businessWebsiteController,
          label: 'Website (Optional)',
          hint: 'Enter your website URL',
          keyboardType: TextInputType.url,
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _businessTaxIdController,
          label: 'Tax ID / Business Registration',
          hint: 'Enter your tax ID or business registration number',
          onChanged: (_) => _markAsChanged(),
        ),
      ],
    );
  }

  Widget _buildCurrencySettingsSection() {
    return _buildSection(
      title: _languageService.getString('currency_financial'),
      icon: Icons.attach_money,
      children: [
        _buildDropdownField(
          label: 'Currency',
          value: _selectedCurrency,
          items: SettingsService.currencyOptions.map((currency) {
            return DropdownMenuItem(
              value: currency['code'],
              child: Text('${currency['code']} - ${currency['name']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCurrency = value!;
              _selectedCurrencySymbol = SettingsService.currencyOptions
                  .firstWhere((c) => c['code'] == value)['symbol']!;
            });
            _markAsChanged();
          },
        ),
        _buildTextField(
          controller: _taxRateController,
          label: 'Tax Rate (%)',
          hint: 'Enter tax rate as percentage',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final rate = double.tryParse(value ?? '');
            if (rate != null && (rate < 0 || rate > 100)) {
              return 'Tax rate must be between 0 and 100';
            }
            return null;
          },
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _defaultOpeningBalanceController,
          label: 'Default Opening Balance',
          hint: 'Enter default opening balance',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _markAsChanged(),
        ),
        _buildDropdownField(
          label: 'Decimal Places',
          value: _selectedDecimalPlaces,
          items: [0, 1, 2, 3].map((places) {
            return DropdownMenuItem(
              value: places,
              child: Text('$places decimal places'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDecimalPlaces = value!;
            });
            _markAsChanged();
          },
        ),
      ],
    );
  }

  Widget _buildReceiptSettingsSection() {
    return _buildSection(
      title: _languageService.getString('receipt_report'),
      icon: Icons.receipt,
      children: [
        _buildTextField(
          controller: _receiptHeaderController,
          label: 'Receipt Header',
          hint: 'Text to display at the top of receipts',
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _receiptFooterController,
          label: 'Receipt Footer',
          hint: 'Text to display at the bottom of receipts',
          maxLines: 2,
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _reportTitleController,
          label: 'Report Title',
          hint: 'Title for printed reports',
          onChanged: (_) => _markAsChanged(),
        ),
        _buildDropdownField(
          label: 'Paper Size',
          value: _selectedPaperSize,
          items: SettingsService.paperSizeOptions.map((size) {
            return DropdownMenuItem(
              value: size,
              child: Text(size),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaperSize = value!;
            });
            _markAsChanged();
          },
        ),
        _buildDropdownField(
          label: 'Print Quality',
          value: _selectedPrintQuality,
          items: SettingsService.printQualityOptions.map((quality) {
            return DropdownMenuItem(
              value: quality,
              child: Text(quality.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPrintQuality = value!;
            });
            _markAsChanged();
          },
        ),
      ],
    );
  }

  Widget _buildUserManagementSection() {
    return _buildSection(
      title: 'User Management',
      icon: Icons.people,
      children: [
        _buildDropdownField(
          label: 'Default Cashier Role',
          value: _selectedDefaultCashierRole,
          items: SettingsService.userRoleOptions.map((role) {
            return DropdownMenuItem(
              value: role['value'],
              child: Text(role['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDefaultCashierRole = value!;
            });
            _markAsChanged();
          },
        ),
        _buildDropdownField(
          label: 'Password Policy',
          value: _selectedPasswordPolicy,
          items: SettingsService.passwordPolicyOptions.map((policy) {
            return DropdownMenuItem(
              value: policy['value'],
              child: Text(policy['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPasswordPolicy = value!;
            });
            _markAsChanged();
          },
        ),
        _buildSwitchField(
          label: 'Auto Login',
          value: _autoLogin,
          onChanged: (value) {
            setState(() {
              _autoLogin = value;
            });
            _markAsChanged();
          },
        ),
        _buildSwitchField(
          label: 'Require Password for Closing',
          value: _requirePasswordForClosing,
          onChanged: (value) {
            setState(() {
              _requirePasswordForClosing = value;
            });
            _markAsChanged();
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSettingsSection() {
    return _buildSection(
      title: _languageService.getString('language'),
      icon: Icons.language,
      children: [
        _buildDropdownField(
          label: _languageService.getString('language'),
          value: _languageService.currentLocale.languageCode,
          items: _languageService.getLanguageOptions().map((lang) {
            return DropdownMenuItem(
              value: lang['code'],
              child: Text(lang['name']!),
            );
          }).toList(),
          onChanged: (value) async {
            if (value != null) {
              await _languageService.setLanguage(value);
              _markAsChanged();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSystemSettingsSection() {
    return _buildSection(
      title: _languageService.getString('system_preferences'),
      icon: Icons.settings,
      children: [
        _buildDropdownField(
          label: 'Date Format',
          value: _selectedDateFormat,
          items: SettingsService.dateFormatOptions.map((format) {
            return DropdownMenuItem(
              value: format['value'],
              child: Text(format['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDateFormat = value!;
            });
            _markAsChanged();
          },
        ),
        _buildDropdownField(
          label: 'Time Format',
          value: _selectedTimeFormat,
          items: SettingsService.timeFormatOptions.map((format) {
            return DropdownMenuItem(
              value: format['value'],
              child: Text(format['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTimeFormat = value!;
            });
            _markAsChanged();
          },
        ),
        _buildDropdownField(
          label: 'Theme',
          value: _selectedTheme,
          items: SettingsService.themeOptions.map((theme) {
            return DropdownMenuItem(
              value: theme['value'],
              child: Text(theme['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTheme = value!;
            });
            _markAsChanged();
          },
        ),
        _buildDropdownField(
          label: 'Font Size',
          value: _selectedFontSize,
          items: SettingsService.fontSizeOptions.map((size) {
            return DropdownMenuItem(
              value: size['value'],
              child: Text(size['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFontSize = value!;
            });
            _markAsChanged();
          },
        ),
        _buildTextField(
          controller: _autoSaveIntervalController,
          label: 'Auto-save Interval (seconds)',
          hint: 'Enter auto-save interval in seconds',
          keyboardType: TextInputType.number,
          validator: (value) {
            final interval = int.tryParse(value ?? '');
            if (interval != null && interval < 5) {
              return 'Auto-save interval must be at least 5 seconds';
            }
            return null;
          },
          onChanged: (_) => _markAsChanged(),
        ),
        _buildTextField(
          controller: _sessionTimeoutController,
          label: 'Session Timeout (minutes)',
          hint: 'Enter session timeout in minutes',
          keyboardType: TextInputType.number,
          validator: (value) {
            final timeout = int.tryParse(value ?? '');
            if (timeout != null && timeout < 1) {
              return 'Session timeout must be at least 1 minute';
            }
            return null;
          },
          onChanged: (_) => _markAsChanged(),
        ),
      ],
    );
  }

  Widget _buildPrintSettingsSection() {
    return _buildSection(
      title: 'Print Settings', // TODO: Localize this title
      icon: Icons.print,
      children: [
        _buildTextField(
          controller: TextEditingController(text: _selectedDefaultPrinter),
          label: 'Default Printer',
          hint: 'Enter default printer name or leave empty for system default',
          onChanged: (value) {
            _selectedDefaultPrinter = value;
            _markAsChanged();
          },
        ),
        _buildSwitchField(
          label: 'Show Print Preview',
          value: _printPreview,
          onChanged: (value) {
            setState(() {
              _printPreview = value;
              _markAsChanged();
            });
          },
        ),
        _buildDropdownField(
          label: 'Print Copies',
          value: _selectedPrintCopies.toString(),
          items: SettingsService.printCopiesOptions.map((copies) {
            return DropdownMenuItem(
              value: copies['value'],
              child: Text(copies['label']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPrintCopies = int.tryParse(value) ?? 1;
                _markAsChanged();
              });
            }
          },
        ),
        _buildDropdownField(
          label: 'Paper Orientation',
          value: _selectedPaperOrientation,
          items: SettingsService.paperOrientationOptions.map((orientation) {
            return DropdownMenuItem(
              value: orientation['value'],
              child: Text(orientation['label']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaperOrientation = value;
                _markAsChanged();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettingsSection() {
    return _buildSection(
      title: _languageService.getString('security_settings'),
      icon: Icons.security,
      children: [
        _buildSwitchField(
          label: _languageService.getString('audit_trail_enabled'),
          value: _auditTrailEnabled,
          onChanged: (value) {
            setState(() {
              _auditTrailEnabled = value;
            });
            _markAsChanged();
          },
        ),
        if (_auditTrailEnabled) ...[
          _buildDropdownField(
            label: _languageService.getString('audit_log_retention'),
            value: _auditLogRetentionDays.toString(),
            items: SettingsService.auditLogRetentionOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _auditLogRetentionDays = int.tryParse(value!) ?? 90;
              });
              _markAsChanged();
            },
          ),
        ],
        _buildSwitchField(
          label: _languageService.getString('session_logging_enabled'),
          value: _sessionLoggingEnabled,
          onChanged: (value) {
            setState(() {
              _sessionLoggingEnabled = value;
            });
            _markAsChanged();
          },
        ),
        if (_sessionLoggingEnabled) ...[
          _buildDropdownField(
            label: _languageService.getString('session_log_retention'),
            value: _sessionLogRetentionDays.toString(),
            items: SettingsService.sessionLogRetentionOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sessionLogRetentionDays = int.tryParse(value!) ?? 30;
              });
              _markAsChanged();
            },
          ),
        ],
        _buildSwitchField(
          label: _languageService.getString('data_encryption_enabled'),
          value: _dataEncryptionEnabled,
          onChanged: (value) {
            setState(() {
              _dataEncryptionEnabled = value;
            });
            _markAsChanged();
          },
        ),
        // Description text for security features
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[900]?.withOpacity(0.2)
                : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _languageService.getString('audit_trail_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.getString('session_logging_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.getString('data_encryption_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSection(
      title: _languageService.getString('data_management'),
      icon: Icons.storage,
      children: [
        _buildSwitchField(
          label: _languageService.getString('auto_backup_enabled'),
          value: _autoBackupEnabled,
          onChanged: (value) {
            setState(() {
              _autoBackupEnabled = value;
            });
            _markAsChanged();
          },
        ),
        if (_autoBackupEnabled) ...[
          _buildTextField(
            label: _languageService.getString('backup_location'),
            hint: 'Documents/MiniMercado/Backups',
            controller: _backupLocationController,
            onChanged: (value) {
              setState(() {
                _backupLocation = value;
              });
              _markAsChanged();
            },
          ),
          _buildDropdownField(
            label: _languageService.getString('backup_frequency'),
            value: _backupFrequency,
            items: SettingsService.backupFrequencyOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _backupFrequency = value!;
              });
              _markAsChanged();
            },
          ),
          _buildTextField(
            label: _languageService.getString('backup_time'),
            hint: '02:00',
            controller: _backupTimeController,
            onChanged: (value) {
              setState(() {
                _backupTime = value;
              });
              _markAsChanged();
            },
          ),
        ],
        _buildDropdownField(
          label: _languageService.getString('data_retention'),
          value: _dataRetentionPeriod.toString(),
          items: SettingsService.dataRetentionOptions.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _dataRetentionPeriod = int.tryParse(value!) ?? 365;
            });
            _markAsChanged();
          },
        ),
        _buildDropdownField(
          label: _languageService.getString('export_format'),
          value: _exportFormat,
          items: SettingsService.exportFormatOptions.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _exportFormat = value!;
            });
            _markAsChanged();
          },
        ),
        // Description text for data management features
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.green[900]?.withOpacity(0.2)
                : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _languageService.getString('auto_backup_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.getString('backup_location_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.getString('backup_frequency_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.getString('data_retention_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.getString('export_format_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveSettings,
            icon: const Icon(Icons.save),
            label: Text(_languageService.getString('save_settings')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _resetToDefaults,
            icon: const Icon(Icons.restore),
            label: Text(_languageService.getString('reset_to_defaults')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessWebsiteController.dispose();
    _businessTaxIdController.dispose();
    _taxRateController.dispose();
    _defaultOpeningBalanceController.dispose();
    _receiptHeaderController.dispose();
    _receiptFooterController.dispose();
    _reportTitleController.dispose();
    _autoSaveIntervalController.dispose();
    _sessionTimeoutController.dispose();
    _backupLocationController.dispose();
    _backupTimeController.dispose();
    super.dispose();
  }
}
