import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String _githubApiUrl = 'https://api.github.com/repos/Nahom8bit/Fast-Balance/releases/latest';
  static const String _currentVersion = '1.0.0';
  
  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? _currentVersion;
        final releaseNotes = data['body'] ?? '';
        final downloadUrl = data['html_url'] ?? '';
        
        if (_isNewerVersion(latestVersion, _currentVersion)) {
          return UpdateInfo(
            version: latestVersion,
            releaseNotes: releaseNotes,
            downloadUrl: downloadUrl,
            isUpdateAvailable: true,
          );
        }
      }
    } catch (e) {
      // Handle network errors silently
    }
    
    return null;
  }
  
  static bool _isNewerVersion(String newVersion, String currentVersion) {
    final newParts = newVersion.split('.').map(int.parse).toList();
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }
    return false;
  }
  
  static Future<void> downloadUpdate(String downloadUrl) async {
    if (await canLaunchUrl(Uri.parse(downloadUrl))) {
      await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
    }
  }
  
  static Future<void> setLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUpdateCheck', DateTime.now().toIso8601String());
  }
  
  static Future<bool> shouldCheckForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('lastUpdateCheck');
    
    if (lastCheck == null) return true;
    
    final lastCheckDate = DateTime.parse(lastCheck);
    final now = DateTime.now();
    final difference = now.difference(lastCheckDate);
    
    // Check for updates once per day
    return difference.inHours >= 24;
  }
}

class UpdateInfo {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final bool isUpdateAvailable;
  
  UpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isUpdateAvailable,
  });
} 