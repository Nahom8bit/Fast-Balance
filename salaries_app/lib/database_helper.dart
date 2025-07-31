import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "BalanceClosing.db";
  static const _databaseVersion = 4; // Incremented version for cashier field

  static const tableRecords = 'closing_records';
  static const tableUsers = 'users';

  // Records table columns
  static const columnId = '_id';
  static const columnDate = 'date';
  static const columnCashier = 'cashier';
  static const columnCash = 'cash';
  static const columnTpa = 'tpa';
  static const columnExpenses = 'expenses';
  static const columnOpeningBalance = 'openingBalance';
  static const columnSales = 'sales';
  static const columnNetResult = 'netResult';
  static const columnDiscrepancy = 'discrepancy';

  // Users table columns
  static const columnUserId = 'id';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnRole = 'role';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

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
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await _createRecordsTable(db);
    await _createUsersTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _createUsersTable(db);
    }
    if (oldVersion < 4) {
      // Add cashier column to existing records table
      await db.execute('ALTER TABLE $tableRecords ADD COLUMN $columnCashier TEXT NOT NULL DEFAULT "Unknown"');
    }
  }

  Future<void> _createRecordsTable(Database db) async {
    await db.execute('''
          CREATE TABLE $tableRecords (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnDate TEXT NOT NULL,
            $columnCashier TEXT NOT NULL,
            $columnCash REAL NOT NULL,
            $columnTpa REAL NOT NULL,
            $columnExpenses REAL NOT NULL,
            $columnOpeningBalance REAL NOT NULL,
            $columnSales REAL NOT NULL,
            $columnNetResult REAL NOT NULL,
            $columnDiscrepancy REAL NOT NULL
          )
          ''');
  }

  Future<void> _createUsersTable(Database db) async {
     await db.execute('''
          CREATE TABLE $tableUsers (
            $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUsername TEXT NOT NULL UNIQUE,
            $columnPassword TEXT NOT NULL,
            $columnRole TEXT NOT NULL
          )
          ''');
    // Add default admin user
    await db.insert(tableUsers, {
      columnUsername: 'admin',
      columnPassword: 'madebynahom@2025',
      columnRole: 'admin'
    });
  }

  Future<int> insertRecord(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableRecords, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRecords() async {
    Database db = await instance.database;
    return await db.query(tableRecords, orderBy: "$columnId DESC");
  }

  Future<List<Map<String, dynamic>>> queryRecordsByDateRange(DateTime? start, DateTime? end) async {
    Database db = await instance.database;
    String whereString = '';
    List<dynamic> whereArguments = [];

    if (start != null) {
      whereString += '$columnDate >= ?';
      whereArguments.add(start.toIso8601String());
    }
    if (end != null) {
      if (whereString.isNotEmpty) whereString += ' AND ';
      whereString += '$columnDate <= ?';
      whereArguments.add(end.toIso8601String());
    }

    return await db.query(
      tableRecords,
      where: whereString.isNotEmpty ? whereString : null,
      whereArgs: whereArguments.isNotEmpty ? whereArguments : null,
      orderBy: "$columnId DESC",
    );
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await instance.database;
    List<Map> results = await db.query(
      tableUsers,
      where: '$columnUsername = ?',
      whereArgs: [username],
    );
    if (results.isNotEmpty) {
      return results.first.cast<String, dynamic>();
    }
    return null;
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, row);
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.database;
    return await db.query(tableUsers);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnUserId];
    return await db.update(tableUsers, row, where: '$columnUserId = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(tableUsers, where: '$columnUserId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCashiers() async {
    Database db = await instance.database;
    return await db.query(
      tableUsers,
      where: '$columnRole = ?',
      whereArgs: ['cashier'],
      columns: [columnUserId, columnUsername],
    );
  }
}
