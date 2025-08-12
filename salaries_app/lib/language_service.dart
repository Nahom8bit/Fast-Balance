import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'country': 'US', 'name': 'English', 'nativeName': 'English'},
    {'code': 'es', 'country': 'ES', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'pt', 'country': 'BR', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'fr', 'country': 'FR', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'de', 'country': 'DE', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'it', 'country': 'IT', 'name': 'Italian', 'nativeName': 'Italiano'},
    {'code': 'ar', 'country': 'SA', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'zh', 'country': 'CN', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'ja', 'country': 'JP', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'ko', 'country': 'KR', 'name': 'Korean', 'nativeName': '한국어'},
  ];

  // Localized strings
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      // Business Information
      'business_information': 'Business Information',
      'business_name': 'Business Name',
      'business_address': 'Business Address',
      'phone_number': 'Phone Number',
      'email_address': 'Email Address',
      'website': 'Website (Optional)',
      'tax_id': 'Tax ID / Business Registration',
      
      // Currency & Financial
      'currency_financial': 'Currency & Financial Settings',
      'currency': 'Currency',
      'tax_rate': 'Tax Rate (%)',
      'default_opening_balance': 'Default Opening Balance',
      'decimal_places': 'Decimal Places',
      
      // Receipt & Report
      'receipt_report': 'Receipt & Report Settings',
      'receipt_header': 'Receipt Header',
      'receipt_footer': 'Receipt Footer',
      'report_title': 'Report Title',
      'paper_size': 'Paper Size',
      'print_quality': 'Print Quality',
      
      // System Preferences
      'system_preferences': 'System Preferences',
      'date_format': 'Date Format',
      'time_format': 'Time Format',
      'theme': 'Theme',
      'font_size': 'Font Size',
      'auto_save_interval': 'Auto-save Interval (seconds)',
      'session_timeout': 'Session Timeout (minutes)',
      
      // Common
      'save_settings': 'Save Settings',
      'reset_to_defaults': 'Reset to Defaults',
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'confirm': 'Confirm',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Messages
      'settings_saved': 'Settings saved successfully!',
      'error_saving': 'Error saving settings: ',
      'error_loading': 'Error loading settings: ',
      'reset_confirmation': 'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
      'settings_reset': 'Settings reset to defaults!',
      'error_resetting': 'Error resetting settings: ',
      
      // Placeholders
      'enter_business_name': 'Enter your business name',
      'enter_business_address': 'Enter your business address',
      'enter_phone': 'Enter your phone number',
      'enter_email': 'Enter your email address',
      'enter_website': 'Enter your website URL',
      'enter_tax_id': 'Enter your tax ID or business registration number',
      'enter_tax_rate': 'Enter tax rate as percentage',
      'enter_opening_balance': 'Enter default opening balance',
      'enter_receipt_header': 'Text to display at the top of receipts',
      'enter_receipt_footer': 'Text to display at the bottom of receipts',
      'enter_report_title': 'Title for printed reports',
      'enter_auto_save': 'Enter auto-save interval in seconds',
      'enter_session_timeout': 'Enter session timeout in minutes',
      
      // Validation
      'business_name_required': 'Business name is required',
      'invalid_email': 'Please enter a valid email address',
      'tax_rate_range': 'Tax rate must be between 0 and 100',
      'auto_save_minimum': 'Auto-save interval must be at least 5 seconds',
      'session_timeout_minimum': 'Session timeout must be at least 1 minute',
      
      // Options
      'decimal_places_0': '0 decimal places',
      'decimal_places_1': '1 decimal place',
      'decimal_places_2': '2 decimal places',
      'decimal_places_3': '3 decimal places',
      'time_12_hour': '12-Hour (AM/PM)',
      'time_24_hour': '24-Hour',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'font_small': 'Small',
      'font_medium': 'Medium',
      'font_large': 'Large',
    },
    'es': {
      // Business Information
      'business_information': 'Información del Negocio',
      'business_name': 'Nombre del Negocio',
      'business_address': 'Dirección del Negocio',
      'phone_number': 'Número de Teléfono',
      'email_address': 'Dirección de Correo',
      'website': 'Sitio Web (Opcional)',
      'tax_id': 'ID Fiscal / Registro Comercial',
      
      // Currency & Financial
      'currency_financial': 'Configuración de Moneda y Finanzas',
      'currency': 'Moneda',
      'tax_rate': 'Tasa de Impuesto (%)',
      'default_opening_balance': 'Saldo de Apertura Predeterminado',
      'decimal_places': 'Lugares Decimales',
      
      // Receipt & Report
      'receipt_report': 'Configuración de Recibos e Informes',
      'receipt_header': 'Encabezado del Recibo',
      'receipt_footer': 'Pie del Recibo',
      'report_title': 'Título del Informe',
      'paper_size': 'Tamaño de Papel',
      'print_quality': 'Calidad de Impresión',
      
      // System Preferences
      'system_preferences': 'Preferencias del Sistema',
      'date_format': 'Formato de Fecha',
      'time_format': 'Formato de Hora',
      'theme': 'Tema',
      'font_size': 'Tamaño de Fuente',
      'auto_save_interval': 'Intervalo de Auto-guardado (segundos)',
      'session_timeout': 'Tiempo de Sesión (minutos)',
      
      // Common
      'save_settings': 'Guardar Configuración',
      'reset_to_defaults': 'Restablecer Valores Predeterminados',
      'settings': 'Configuración',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'reset': 'Restablecer',
      'confirm': 'Confirmar',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      
      // Messages
      'settings_saved': '¡Configuración guardada exitosamente!',
      'error_saving': 'Error al guardar la configuración: ',
      'error_loading': 'Error al cargar la configuración: ',
      'reset_confirmation': '¿Está seguro de que desea restablecer toda la configuración a sus valores predeterminados? Esta acción no se puede deshacer.',
      'settings_reset': '¡Configuración restablecida a valores predeterminados!',
      'error_resetting': 'Error al restablecer la configuración: ',
      
      // Placeholders
      'enter_business_name': 'Ingrese el nombre de su negocio',
      'enter_business_address': 'Ingrese la dirección de su negocio',
      'enter_phone': 'Ingrese su número de teléfono',
      'enter_email': 'Ingrese su dirección de correo electrónico',
      'enter_website': 'Ingrese la URL de su sitio web',
      'enter_tax_id': 'Ingrese su ID fiscal o número de registro comercial',
      'enter_tax_rate': 'Ingrese la tasa de impuesto como porcentaje',
      'enter_opening_balance': 'Ingrese el saldo de apertura predeterminado',
      'enter_receipt_header': 'Texto para mostrar en la parte superior de los recibos',
      'enter_receipt_footer': 'Texto para mostrar en la parte inferior de los recibos',
      'enter_report_title': 'Título para informes impresos',
      'enter_auto_save': 'Ingrese el intervalo de auto-guardado en segundos',
      'enter_session_timeout': 'Ingrese el tiempo de sesión en minutos',
      
      // Validation
      'business_name_required': 'El nombre del negocio es requerido',
      'invalid_email': 'Por favor ingrese una dirección de correo válida',
      'tax_rate_range': 'La tasa de impuesto debe estar entre 0 y 100',
      'auto_save_minimum': 'El intervalo de auto-guardado debe ser de al menos 5 segundos',
      'session_timeout_minimum': 'El tiempo de sesión debe ser de al menos 1 minuto',
      
      // Options
      'decimal_places_0': '0 lugares decimales',
      'decimal_places_1': '1 lugar decimal',
      'decimal_places_2': '2 lugares decimales',
      'decimal_places_3': '3 lugares decimales',
      'time_12_hour': '12-Horas (AM/PM)',
      'time_24_hour': '24-Horas',
      'theme_light': 'Claro',
      'theme_dark': 'Oscuro',
      'theme_system': 'Sistema',
      'font_small': 'Pequeño',
      'font_medium': 'Mediano',
      'font_large': 'Grande',
    },
    'pt': {
      // Business Information
      'business_information': 'Informações do Negócio',
      'business_name': 'Nome do Negócio',
      'business_address': 'Endereço do Negócio',
      'phone_number': 'Número de Telefone',
      'email_address': 'Endereço de Email',
      'website': 'Site (Opcional)',
      'tax_id': 'ID Fiscal / Registro Comercial',
      
      // Currency & Financial
      'currency_financial': 'Configurações de Moeda e Finanças',
      'currency': 'Moeda',
      'tax_rate': 'Taxa de Imposto (%)',
      'default_opening_balance': 'Saldo de Abertura Padrão',
      'decimal_places': 'Casas Decimais',
      
      // Receipt & Report
      'receipt_report': 'Configurações de Recibos e Relatórios',
      'receipt_header': 'Cabeçalho do Recibo',
      'receipt_footer': 'Rodapé do Recibo',
      'report_title': 'Título do Relatório',
      'paper_size': 'Tamanho do Papel',
      'print_quality': 'Qualidade de Impressão',
      
      // System Preferences
      'system_preferences': 'Preferências do Sistema',
      'date_format': 'Formato de Data',
      'time_format': 'Formato de Hora',
      'theme': 'Tema',
      'font_size': 'Tamanho da Fonte',
      'auto_save_interval': 'Intervalo de Auto-salvamento (segundos)',
      'session_timeout': 'Tempo de Sessão (minutos)',
      
      // Common
      'save_settings': 'Salvar Configurações',
      'reset_to_defaults': 'Restaurar Padrões',
      'settings': 'Configurações',
      'save': 'Salvar',
      'cancel': 'Cancelar',
      'reset': 'Restaurar',
      'confirm': 'Confirmar',
      'loading': 'Carregando...',
      'error': 'Erro',
      'success': 'Sucesso',
      
      // Messages
      'settings_saved': 'Configurações salvas com sucesso!',
      'error_saving': 'Erro ao salvar configurações: ',
      'error_loading': 'Erro ao carregar configurações: ',
      'reset_confirmation': 'Tem certeza de que deseja restaurar todas as configurações para seus valores padrão? Esta ação não pode ser desfeita.',
      'settings_reset': 'Configurações restauradas para padrões!',
      'error_resetting': 'Erro ao restaurar configurações: ',
      
      // Placeholders
      'enter_business_name': 'Digite o nome do seu negócio',
      'enter_business_address': 'Digite o endereço do seu negócio',
      'enter_phone': 'Digite seu número de telefone',
      'enter_email': 'Digite seu endereço de email',
      'enter_website': 'Digite a URL do seu site',
      'enter_tax_id': 'Digite seu ID fiscal ou número de registro comercial',
      'enter_tax_rate': 'Digite a taxa de imposto como porcentagem',
      'enter_opening_balance': 'Digite o saldo de abertura padrão',
      'enter_receipt_header': 'Texto para exibir no topo dos recibos',
      'enter_receipt_footer': 'Texto para exibir na parte inferior dos recibos',
      'enter_report_title': 'Título para relatórios impressos',
      'enter_auto_save': 'Digite o intervalo de auto-salvamento em segundos',
      'enter_session_timeout': 'Digite o tempo de sessão em minutos',
      
      // Validation
      'business_name_required': 'Nome do negócio é obrigatório',
      'invalid_email': 'Por favor, digite um endereço de email válido',
      'tax_rate_range': 'Taxa de imposto deve estar entre 0 e 100',
      'auto_save_minimum': 'Intervalo de auto-salvamento deve ser de pelo menos 5 segundos',
      'session_timeout_minimum': 'Tempo de sessão deve ser de pelo menos 1 minuto',
      
      // Options
      'decimal_places_0': '0 casas decimais',
      'decimal_places_1': '1 casa decimal',
      'decimal_places_2': '2 casas decimais',
      'decimal_places_3': '3 casas decimais',
      'time_12_hour': '12-Horas (AM/PM)',
      'time_24_hour': '24-Horas',
      'theme_light': 'Claro',
      'theme_dark': 'Escuro',
      'theme_system': 'Sistema',
      'font_small': 'Pequeno',
      'font_medium': 'Médio',
      'font_large': 'Grande',
    },
  };

  // Initialize language service
  Future<void> initialize() async {
    await _loadSavedLanguage();
  }

  // Load saved language from preferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        final language = supportedLanguages.firstWhere(
          (lang) => lang['code'] == languageCode,
          orElse: () => supportedLanguages.first,
        );
        
        _currentLocale = Locale(language['code']!, language['country']!);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, default to English
      _currentLocale = const Locale('en', 'US');
    }
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    try {
      final language = supportedLanguages.firstWhere(
        (lang) => lang['code'] == languageCode,
        orElse: () => supportedLanguages.first,
      );
      
      _currentLocale = Locale(language['code']!, language['country']!);
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    } catch (e) {
      // If there's an error, default to English
      _currentLocale = const Locale('en', 'US');
    }
  }

  // Get localized string
  String getString(String key) {
    final languageCode = _currentLocale.languageCode;
    final strings = _localizedStrings[languageCode] ?? _localizedStrings['en']!;
    return strings[key] ?? key;
  }

  // Get current language name
  String getCurrentLanguageName() {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['name']!;
  }

  // Get current language native name
  String getCurrentLanguageNativeName() {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['nativeName']!;
  }

  // Get language options for dropdown
  List<Map<String, String>> getLanguageOptions() {
    return supportedLanguages.map((lang) => {
      'code': lang['code']!,
      'name': '${lang['name']} (${lang['nativeName']})',
    }).toList();
  }

  // Check if RTL language
  bool isRTL() {
    return _currentLocale.languageCode == 'ar';
  }

  // Get text direction
  TextDirection getTextDirection() {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }
}
