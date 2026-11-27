import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _fileName = 'users_data.json';
  static const int nimUserId = 1619; // 1499 + 120 (NIM: 20240801120)

  // In-memory cache agar selalu berjalan mulus di Web, Android, dan Windows
  static List<Map<String, dynamic>>? _inMemoryUsers;

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
    // 1. Jika sudah ada di memori, gunakan data memori
    if (_inMemoryUsers != null && _inMemoryUsers!.isNotEmpty) {
      return _inMemoryUsers!;
    }

    // 2. Coba baca dari file lokal jika didukung platform
    try {
      final file = await _getFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content);
        _inMemoryUsers = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        return _inMemoryUsers!;
      }
    } catch (_) {}

    // 3. Jika belum ada, inisialisasi dari API
    await resetToDefault();
    return _inMemoryUsers ?? _fallbackUsers;
  }

  static Future<void> _writeLocal(List<dynamic> data) async {
    _inMemoryUsers = data.map((e) => Map<String, dynamic>.from(e)).toList();
    try {
      final file = await _getFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(data));
      }
    } catch (_) {}
  }

  // ==========================================
  // RESET DATA KE AWAL (DARI API)
  // ==========================================

  static Future<void> resetToDefault() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        _inMemoryUsers = list.map((e) => Map<String, dynamic>.from(e)).toList();
        
        try {
          final file = await _getFile();
          if (file != null) {
            await file.writeAsString(response.body);
          }
        } catch (_) {}
        return;
      }
    } catch (_) {}

    // Fallback jika API sedang tidak terjangkau
    _inMemoryUsers = List<Map<String, dynamic>>.from(_fallbackUsers);
    try {
      final file = await _getFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(_fallbackUsers));
      }
    } catch (_) {}
  }

  // ==========================================
  // GET: Mengambil Seluruh User
  // ==========================================

  static Future<List<dynamic>> getUsers() async {
    return await _readLocal();
  }

  // ==========================================
  // GET: Mengambil User Berdasarkan ID
  // ==========================================

  static Future<dynamic> getUser(int id) async {
    // HTTP GET ke API (demonstrasi REST API)
    try {
      await http.get(Uri.parse('$_baseUrl/users/$id'));
    } catch (_) {}

    final users = await _readLocal();
    final matches = users.where((u) => u['id'] == id);
    if (matches.isEmpty) {
      throw Exception('User dengan ID $id tidak ditemukan');
    }
    return matches.first;
  }

  // ==========================================
  // POST: Menambahkan User Baru (ID NIM = 1619)
  // ==========================================

  static Future<dynamic> createUser(String name, String email) async {
    // HTTP POST ke API (demonstrasi REST API)
    try {
      await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': nimUserId,
          'name': name,
          'email': email,
        }),
      );
    } catch (_) {}

    final users = await _readLocal();
    final newUser = {
      'id': nimUserId,
      'name': name,
      'email': email,
      'address': {'city': 'Jakarta'},
    };

    // Hapus data lama jika ID sama, lalu masukkan data baru
    users.removeWhere((u) => u['id'] == nimUserId);
    users.add(newUser);
    await _writeLocal(users);

    return newUser;
  }

  // ==========================================
  // PUT: Memperbarui Nama dan Email User
  // ==========================================

  static Future<dynamic> updateUser(
    int id,
    String name,
    String email,
  ) async {
    // HTTP PUT ke API (demonstrasi REST API)
    try {
      await http.put(
        Uri.parse('$_baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': id,
          'name': name,
          'email': email,
        }),
      );
    } catch (_) {}

    final users = await _readLocal();
    final idx = users.indexWhere((u) => u['id'] == id);
    if (idx == -1) {
      throw Exception('User dengan ID $id tidak ditemukan');
    }

    users[idx]['name'] = name;
    users[idx]['email'] = email;
    await _writeLocal(users);
    return users[idx];
  }

  // ==========================================
  // PATCH: Memperbarui Nama + " - Flutter Developer"
  // ==========================================

  static Future<dynamic> patchUser(int id, String name) async {
    final patchedName = '$name - Flutter Developer';

    // HTTP PATCH ke API (demonstrasi REST API)
    try {
      await http.patch(
        Uri.parse('$_baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'name': patchedName}),
      );
    } catch (_) {}

    final users = await _readLocal();
    final idx = users.indexWhere((u) => u['id'] == id);
    if (idx == -1) {
      throw Exception('User dengan ID $id tidak ditemukan');
    }

    users[idx]['name'] = patchedName;
    await _writeLocal(users);
    return users[idx];
  }

  // ==========================================
  // DELETE: Menghapus User Berdasarkan ID
  // ==========================================

  static Future<bool> deleteUser(int id) async {
    // HTTP DELETE ke API (demonstrasi REST API)
    try {
      await http.delete(Uri.parse('$_baseUrl/users/$id'));
    } catch (_) {}

    final users = await _readLocal();
    final len = users.length;
    users.removeWhere((u) => u['id'] == id);

    if (users.length < len) {
      await _writeLocal(users);
      return true;
    }
    return false;
  }

  // ==========================================
  // DATA FALLBACK
  // ==========================================

  static final List<Map<String, dynamic>> _fallbackUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'address': {'city': 'Gwenborough'},
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'address': {'city': 'Wisokyburgh'},
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'address': {'city': 'McKenziehaven'},
    },
    {
      'id': 4,
      'name': 'Patricia Lebsack',
      'email': 'Julianne.OConner@kory.org',
      'address': {'city': 'South Elvis'},
    },
    {
      'id': 5,
      'name': 'Chelsey Dietrich',
      'email': 'Lucio_Hettinger@annie.ca',
      'address': {'city': 'Roscoeview'},
    },
  ];
}
