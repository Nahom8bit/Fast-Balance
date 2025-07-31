import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyFormatter {
  static late SharedPreferences _prefs;
  static String _currencySymbol = 'L.K.R';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currencySymbol = _prefs.getString('currency') ?? 'L.K.R';
  }

  static String format(double value) {
    final format = NumberFormat.currency(
      symbol: '$_currencySymbol ',
      decimalDigits: 2,
    );
    return format.format(value);
  }

  static void setCurrency(String currency) {
    _currencySymbol = currency;
    _prefs.setString('currency', currency);
  }
}
