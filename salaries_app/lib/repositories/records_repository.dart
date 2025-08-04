import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database_helper.dart';

/// Repository for managing closing records with caching
class RecordsRepository {
  static final RecordsRepository _instance = RecordsRepository._internal();
  factory RecordsRepository() => _instance;
  RecordsRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get records by date range with caching
  Future<List<Map<String, dynamic>>> getRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final key = _generateCacheKey(startDate, endDate);
    
    // Check cache first
    if (_cache.containsKey(key) && _isCacheValid(key)) {
      if (kDebugMode) {
        print('RecordsRepository: Returning cached data for $key');
      }
      return _cache[key]!;
    }

    // Fetch from database
    if (kDebugMode) {
      print('RecordsRepository: Fetching fresh data for $key');
    }
    
    final records = await _dbHelper.queryRecordsByDateRange(
      startDate,
      endDate.add(const Duration(days: 1)),
    );

    // Cache results
    _cache[key] = records;
    _cacheTimestamps[key] = DateTime.now();

    return records;
  }

  /// Get all records with caching
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    const key = 'all_records';
    
    if (_cache.containsKey(key) && _isCacheValid(key)) {
      if (kDebugMode) {
        print('RecordsRepository: Returning cached all records');
      }
      return _cache[key]!;
    }

    if (kDebugMode) {
      print('RecordsRepository: Fetching fresh all records');
    }

    final records = await _dbHelper.queryAllRecords();
    
    _cache[key] = records;
    _cacheTimestamps[key] = DateTime.now();

    return records;
  }

  /// Save a new record and invalidate cache
  Future<int> saveRecord(Map<String, dynamic> record) async {
    final result = await _dbHelper.insertRecord(record);
    
    // Invalidate cache after saving
    _invalidateCache();
    
    if (kDebugMode) {
      print('RecordsRepository: Saved record and invalidated cache');
    }
    
    return result;
  }

  /// Get cashiers with caching
  Future<List<Map<String, dynamic>>> getCashiers() async {
    const key = 'cashiers';
    
    if (_cache.containsKey(key) && _isCacheValid(key)) {
      return _cache[key]!;
    }

    final cashiers = await _dbHelper.getCashiers();
    
    _cache[key] = cashiers;
    _cacheTimestamps[key] = DateTime.now();

    return cashiers;
  }

  /// Get users with caching
  Future<List<Map<String, dynamic>>> getUsers() async {
    const key = 'users';
    
    if (_cache.containsKey(key) && _isCacheValid(key)) {
      return _cache[key]!;
    }

    final users = await _dbHelper.queryAllUsers();
    
    _cache[key] = users;
    _cacheTimestamps[key] = DateTime.now();

    return users;
  }

  /// Get a specific user
  Future<Map<String, dynamic>?> getUser(String username) async {
    return await _dbHelper.getUser(username);
  }

  /// Clear all cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    if (kDebugMode) {
      print('RecordsRepository: Cache cleared');
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _cache.length,
      'cacheKeys': _cache.keys.toList(),
      'timestamps': _cacheTimestamps.map((key, value) => MapEntry(key, value.toIso8601String())),
    };
  }

  /// Generate cache key from date range
  String _generateCacheKey(DateTime start, DateTime end) {
    return '${start.toIso8601String()}_${end.toIso8601String()}';
  }

  /// Check if cache entry is still valid
  bool _isCacheValid(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key]!;
    final now = DateTime.now();
    
    return now.difference(timestamp) < _cacheExpiry;
  }

  /// Invalidate all cache entries
  void _invalidateCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Invalidate specific cache entries
  void _invalidateCacheByPattern(String pattern) {
    final keysToRemove = _cache.keys.where((key) => key.contains(pattern)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
} 