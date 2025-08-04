import 'dart:async';
import 'package:flutter/foundation.dart';

/// Controller for managing form calculations with debouncing
class CalculationController extends ChangeNotifier {
  Timer? _debounceTimer;
  final Map<String, double> _values = {};
  
  // Calculated results
  double _netResult = 0.0;
  double _discrepancy = 0.0;
  double _totalExpenses = 0.0;
  
  // Getters for calculated values
  double get netResult => _netResult;
  double get discrepancy => _discrepancy;
  double get totalExpenses => _totalExpenses;
  
  // Get current values
  double get cash => _values['cash'] ?? 0.0;
  double get tpa => _values['tpa'] ?? 0.0;
  double get openingBalance => _values['openingBalance'] ?? 0.0;
  double get sales => _values['sales'] ?? 0.0;
  double get expenses => _values['expenses'] ?? 0.0;

  /// Update a specific value and trigger debounced calculation
  void updateValue(String key, double value) {
    _values[key] = value;
    _debounceCalculation();
  }

  /// Update multiple values at once
  void updateValues(Map<String, double> newValues) {
    _values.addAll(newValues);
    _debounceCalculation();
  }

  /// Update expenses list and recalculate
  void updateExpenses(List<Map<String, dynamic>> expenses) {
    _totalExpenses = expenses.fold<double>(
      0.0, 
      (sum, expense) => sum + (expense['amount'] as double? ?? 0.0)
    );
    _values['expenses'] = _totalExpenses;
    _debounceCalculation();
  }

  /// Clear all values
  void clearValues() {
    _values.clear();
    _netResult = 0.0;
    _discrepancy = 0.0;
    _totalExpenses = 0.0;
    notifyListeners();
  }

  /// Get all current values as a map
  Map<String, double> get allValues => Map.from(_values);

  /// Perform the actual calculations
  void _performCalculations() {
    final cash = _values['cash'] ?? 0.0;
    final tpa = _values['tpa'] ?? 0.0;
    final openingBalance = _values['openingBalance'] ?? 0.0;
    final sales = _values['sales'] ?? 0.0;
    final expenses = _values['expenses'] ?? 0.0;

    // Calculate net result (counted amount)
    _netResult = cash + tpa + expenses - openingBalance;
    
    // Calculate discrepancy (difference between counted and sales)
    _discrepancy = _netResult - sales;

    if (kDebugMode) {
      print('CalculationController: Recalculated values');
      print('  Cash: $cash');
      print('  TPA: $tpa');
      print('  Expenses: $expenses');
      print('  Opening Balance: $openingBalance');
      print('  Sales: $sales');
      print('  Net Result: $_netResult');
      print('  Discrepancy: $_discrepancy');
    }
  }

  /// Debounced calculation to prevent excessive updates
  void _debounceCalculation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performCalculations();
      notifyListeners();
    });
  }

  /// Force immediate calculation (for testing or immediate feedback)
  void forceCalculation() {
    _debounceTimer?.cancel();
    _performCalculations();
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Get calculation summary for debugging
  Map<String, dynamic> getCalculationSummary() {
    return {
      'values': Map.from(_values),
      'netResult': _netResult,
      'discrepancy': _discrepancy,
      'totalExpenses': _totalExpenses,
      'isBalanced': _discrepancy.abs() < 0.01,
    };
  }
} 