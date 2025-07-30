import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "BalanceClosing.db";
  static const _databaseVersion = 1;

  static const table = 'closing_records';

  static const columnId = '_id';
  static const columnDate = 'date';
  static const columnOpeningBalance = 'openingBalance';
  static const columnCashSales = 'cashSales';
  static const columnTpaSales = 'tpaSales';
  static const columnTotalSales = 'totalSales';
  static const columnTotalExpenses = 'totalExpenses';
  static const columnCashOnHand = 'cashOnHand';
  static const columnExpectedCash = 'expectedCash';
  static const columnDifference = 'difference';
  static const columnStatus = 'status';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnDate TEXT NOT NULL,
            $columnOpeningBalance REAL NOT NULL,
            $columnCashSales REAL NOT NULL,
            $columnTpaSales REAL NOT NULL,
            $columnTotalSales REAL NOT NULL,
            $columnTotalExpenses REAL NOT NULL,
            $columnCashOnHand REAL NOT NULL,
            $columnExpectedCash REAL NOT NULL,
            $columnDifference REAL NOT NULL,
            $columnStatus TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
