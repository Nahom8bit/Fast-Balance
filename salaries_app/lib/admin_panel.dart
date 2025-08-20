import 'package:flutter/material.dart';
import 'package:balancer/record_detail_screen.dart';
import 'package:balancer/dashboard_screen.dart';
import 'package:balancer/user_management_screen.dart';
import 'database_helper.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'services/keyboard_shortcuts_service.dart';
import 'services/enhanced_export_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  AdminPanelState createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCashier = 'All';
  List<String> _availableCashiers = ['All'];
  
  // Bulk operations state
  Set<int> _selectedRecords = {};
  bool _selectAllMode = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecords() async {
    final records = await dbHelper.queryAllRecords();
    setState(() {
      _allRecords = records;
      _filteredRecords = records;
      _availableCashiers = ['All', ...records
          .map((r) => r[DatabaseHelper.columnCashier] as String?)
          .where((cashier) => cashier != null)
          .cast<String>()
          .toSet()];
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allRecords);
    
    // Apply date range filter
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime.parse(record[DatabaseHelper.columnDate]);
        if (_startDate != null && recordDate.isBefore(_startDate!)) return false;
        if (_endDate != null && recordDate.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
        return true;
      }).toList();
    }
    
    // Apply cashier filter
    if (_selectedCashier != 'All') {
      filtered = filtered.where((record) => 
          record[DatabaseHelper.columnCashier] == _selectedCashier).toList();
    }
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((record) {
        final cashier = (record[DatabaseHelper.columnCashier] ?? '').toString().toLowerCase();
        final date = DateTime.parse(record[DatabaseHelper.columnDate]);
        final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
        final recordId = record[DatabaseHelper.columnId].toString();
        
        return cashier.contains(searchTerm) || 
               formattedDate.contains(searchTerm) ||
               recordId.contains(searchTerm);
      }).toList();
    }
    
    setState(() {
      _filteredRecords = filtered;
    });
  }

  void _filterRecords() {
    _applyFilters();
  }
  
  void _toggleSelectAll() {
    setState(() {
      if (_selectAllMode) {
        _selectedRecords.clear();
        _selectAllMode = false;
      } else {
        _selectedRecords = _filteredRecords.map((record) => record[DatabaseHelper.columnId] as int).toSet();
        _selectAllMode = true;
      }
    });
  }
  
  void _toggleRecordSelection(int recordId) {
    setState(() {
      if (_selectedRecords.contains(recordId)) {
        _selectedRecords.remove(recordId);
      } else {
        _selectedRecords.add(recordId);
      }
      _selectAllMode = _selectedRecords.length == _filteredRecords.length;
    });
  }
  
  void _clearSelection() {
    setState(() {
      _selectedRecords.clear();
      _selectAllMode = false;
    });
  }
  
  Future<void> _bulkDelete() async {
    if (_selectedRecords.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Bulk Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedRecords.length} selected record(s)?\n\nThis action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // Note: deleteRecord method would need to be implemented in DatabaseHelper
        // For now, we'll just clear the selection and reload
        _clearSelection();
        _loadRecords();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Delete feature will be implemented in database helper'),
                ],
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Failed to delete records: $e')),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _bulkExport() async {
    if (_selectedRecords.isEmpty) return;
    
    final selectedData = _filteredRecords.where((record) => 
        _selectedRecords.contains(record[DatabaseHelper.columnId])).toList();
    
    EnhancedExportService.showExportDialog(context, selectedData);
  }
  


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _filterRecords();
    }
  }

  Future<void> _exportToCsv() async {
    if (_filteredRecords.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records to export.')),
        );
      }
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Date', 'Cashier', 'Cash', 'TPA', 'Expenses', 'Opening Balance', 'Sales', 'Net Result', 'Discrepancy']);
    
    for (var record in _filteredRecords) {
      final date = DateTime.parse(record[DatabaseHelper.columnDate]);
      final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      
      rows.add([
        record[DatabaseHelper.columnId],
        formattedDate,
        record[DatabaseHelper.columnCashier] ?? 'Unknown',
        record['cash'] ?? 0,
        record['tpa'] ?? 0,
        record['expenses'] ?? 0,
        record['openingBalance'] ?? 0,
        record['sales'] ?? 0,
        record['netResult'] ?? 0,
        record['discrepancy'] ?? 0,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    
    final now = DateTime.now();
    final dateStr = "${now.day}-${now.month}-${now.year}";
    
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV File',
      fileName: 'closing_records_$dateStr.csv',
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${_filteredRecords.length} records to CSV'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsWrapper(
      shortcuts: {
        KeyboardShortcutsService.refreshShortcut: _loadRecords,
        KeyboardShortcutsService.searchShortcut: () => _searchController.selection = TextSelection(baseOffset: 0, extentOffset: _searchController.text.length),
        KeyboardShortcutsService.exportShortcut: () => EnhancedExportService.showExportDialog(context, _filteredRecords),
        KeyboardShortcutsService.helpShortcut: () => KeyboardShortcutsService.showShortcutsHelp(context),
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel - All Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Keyboard Shortcuts (F1)',
            onPressed: () => KeyboardShortcutsService.showShortcutsHelp(context),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Export Data (Ctrl+X)',
            onSelected: (value) {
              switch (value) {
                case 'enhanced':
                  EnhancedExportService.showExportDialog(context, _filteredRecords);
                  break;
                case 'csv':
                  _exportToCsv();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'enhanced',
                child: Row(
                  children: [
                    Icon(Icons.file_download, size: 18),
                    SizedBox(width: 8),
                    Text('Enhanced Export...'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 18),
                    SizedBox(width: 8),
                    Text('Quick CSV Export'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildDateFilter(),
          if (_selectedRecords.isNotEmpty) _buildBulkOperationsBar(),
          _buildRecordsList(),
        ],
      ),
    )
    );
  }

  Widget _buildBulkOperationsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
          bottom: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            '${_selectedRecords.length} selected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _bulkExport,
            icon: const Icon(Icons.download),
            label: const Text('Export Selected'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue[700]),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Delete Selected'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by cashier, date, or record ID...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Filter row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCashier,
                  decoration: InputDecoration(
                    labelText: 'Filter by Cashier',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _availableCashiers.map((cashier) {
                    return DropdownMenuItem(
                      value: cashier,
                      child: Text(cashier),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCashier = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  if (_filteredRecords.isNotEmpty) ...[
                    Checkbox(
                      value: _selectAllMode,
                      tristate: true,
                      onChanged: (value) => _toggleSelectAll(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select All',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_filteredRecords.length} records',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return Expanded(
      child: _filteredRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No records found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isNotEmpty || _selectedCashier != 'All' || _startDate != null || _endDate != null
                        ? 'Try adjusting your filters'
                        : 'No closing records available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  if (_searchController.text.isNotEmpty || _selectedCashier != 'All' || _startDate != null || _endDate != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedCashier = 'All';
                          _startDate = null;
                          _endDate = null;
                        });
                        _applyFilters();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                final record = _filteredRecords[index];
                final date = DateTime.parse(record[DatabaseHelper.columnDate]);
                final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                final cashierName = record[DatabaseHelper.columnCashier] ?? 'Unknown';
                final sales = record['sales'] ?? 0;
                final expenses = record['expenses'] ?? 0;
                final discrepancy = record['discrepancy'] ?? 0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RecordDetailScreen(record: record),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _selectedRecords.contains(record[DatabaseHelper.columnId]),
                                  onChanged: (value) => _toggleRecordSelection(record[DatabaseHelper.columnId]),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cashierName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: discrepancy == 0 
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ID: ${record[DatabaseHelper.columnId]}',
                                    style: TextStyle(
                                      color: discrepancy == 0 ? Colors.green[700] : Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildQuickStat('Sales', sales, Colors.green),
                                const SizedBox(width: 16),
                                _buildQuickStat('Expenses', expenses, Colors.red),
                                const SizedBox(width: 16),
                                _buildQuickStat('Discrepancy', discrepancy.abs(), 
                                    discrepancy == 0 ? Colors.green : Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildQuickStat(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Kz ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(_startDate == null ? 'Start Date' : "${_startDate!.toLocal()}".split(' ')[0]),
            onPressed: () => _selectDate(context, true),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(_endDate == null ? 'End Date' : "${_endDate!.toLocal()}".split(' ')[0]),
            onPressed: () => _selectDate(context, false),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _loadRecords();
              });
            },
          )
        ],
      ),
    );
  }

}
