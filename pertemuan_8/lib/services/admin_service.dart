import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/admin.dart';

class AdminService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _fileName = 'admins_data.json';
  static const int nimAdminId = 912; // 792 + 120 (NIM: 20240801120)

  // In-memory cache agar selalu berjalan mulus di Web, Android, dan Windows
  static List<Map<String, dynamic>>? _inMemoryAdmins;

  // ==========================================
  // FILE HELPER & CROSS-PLATFORM STORAGE
  // ==========================================

  static Future<String> getJsonFilePath() async {
    if (kIsWeb) {
      return 'In-Memory Storage (Web Browser)';
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}${Platform.pathSeparator}$_fileName';
    } catch (_) {
      return 'In-Memory Storage';
    }
  }

  static Future<File?> _getFile() async {
    if (kIsWeb) return null;
    try {
      final path = await getJsonFilePath();
      return File(path);
    } catch (_) {
      return null;
    }
  }

  static Future<List<dynamic>> _readLocal() async {
    if (_inMemoryAdmins != null && _inMemoryAdmins!.isNotEmpty) {
      return _inMemoryAdmins!;
    }

    try {
      final file = await _getFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content);
        _inMemoryAdmins = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        return _inMemoryAdmins!;
      }
    } catch (_) {}

    await resetToDefault();
    return _inMemoryAdmins ?? _fallbackAdmins;
  }

  static Future<void> _writeLocal(List<dynamic> data) async {
    _inMemoryAdmins = data.map((e) => Map<String, dynamic>.from(e)).toList();
    try {
      final file = await _getFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(data));
      }
    } catch (_) {}
  }

  // ==========================================
  // RESET DATA ADMIN
  // ==========================================

  static Future<void> resetToDefault() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> apiData = jsonDecode(response.body);

        List<Map<String, dynamic>> admins = apiData.map((user) {
          String dept = '';
          if (user['company'] != null && user['company'] is Map) {
            dept = user['company']['name']?.toString() ?? '';
          }
          return {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'department': dept,
          };
        }).toList();

        // Tambahkan Admin dengan ID berdasarkan NIM (792 + 120 = 912)
        admins.removeWhere((a) => a['id'] == nimAdminId);
        admins.add({
          'id': nimAdminId,
          'name': 'Anggiant Dwi Raka',
          'email': 'anggiant@admin.com',
          'department': 'IT Department',
        });

        _inMemoryAdmins = admins;

        try {
          final file = await _getFile();
          if (file != null) {
            await file.writeAsString(jsonEncode(admins));
          }
        } catch (_) {}
        return;
      }
    } catch (_) {}

    // Fallback jika API gagal
    _inMemoryAdmins = List<Map<String, dynamic>>.from(_fallbackAdmins);
    try {
      final file = await _getFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(_fallbackAdmins));
      }
    } catch (_) {}
  }

  // ==========================================
  // GET: Mengambil Semua Admin
  // ==========================================

  static Future<List<Admin>> getAdmins() async {
    final data = await _readLocal();
    return data.map((json) => Admin.fromJson(json)).toList();
  }

  // ==========================================
  // GET: Mengambil Admin Berdasarkan ID
  // ==========================================

  static Future<Admin> getAdmin(int id) async {
    final data = await _readLocal();
    final matches = data.where((a) => a['id'] == id);
    if (matches.isEmpty) {
      throw Exception('Admin dengan ID $id tidak ditemukan');
    }
    return Admin.fromJson(matches.first);
  }

  // ==========================================
  // DELETE: Menghapus Admin Berdasarkan ID
  // ==========================================

  static Future<bool> deleteAdmin(int id) async {
    // HTTP DELETE ke API (demonstrasi REST API)
    try {
      await http.delete(Uri.parse('$_baseUrl/users/$id'));
    } catch (_) {}

    final data = await _readLocal();
    final len = data.length;
    data.removeWhere((a) => a['id'] == id);

    if (data.length < len) {
      await _writeLocal(data);
      return true;
    }
    return false;
  }

  // ==========================================
  // DATA FALLBACK
  // ==========================================

  static final List<Map<String, dynamic>> _fallbackAdmins = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'department': 'Romaguera-Crona',
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'department': 'Deckow-Crist',
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'department': 'Romaguera-Jacobson',
    },
    {
      'id': 4,
      'name': 'Patricia Lebsack',
      'email': 'Julianne.OConner@kory.org',
      'department': 'Robel-Corkery',
    },
    {
      'id': 5,
      'name': 'Chelsey Dietrich',
      'email': 'Lucio_Hettinger@annie.ca',
      'department': 'Keebler LLC',
    },
    {
      'id': nimAdminId,
      'name': 'Anggiant Dwi Raka',
      'email': 'anggiant@admin.com',
      'department': 'IT Department',
    },
  ];
}
