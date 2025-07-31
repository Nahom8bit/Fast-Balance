import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_formatter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'Kz'; 

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? 'Kz';
    });
  }

  Future<void> _setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    CurrencyFormatter.setCurrency(currency);
    setState(() {
      _selectedCurrency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Currency'),
            subtitle: const Text('Select your preferred currency'),
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _setCurrency(newValue);
                }
              },
              items: CurrencyFormatter.getAvailableCurrencies()
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
