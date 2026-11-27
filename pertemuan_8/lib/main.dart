// main.dart
// Praktikum 8 - CRUD User & Admin
// NIM: 20240801120 | Anggiant Dwi Raka
// ID User: 1619 (1499 + 120)
// ID Admin: 912  (792 + 120)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'models/admin.dart';
import 'services/api_service.dart';
import 'services/admin_service.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================
// MAIN APP
// ==========================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale locale = const Locale('id');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Praktikum 8 - CRUD User & Admin',
      locale: locale,
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MainScreen(
        onLanguageChanged: (value) {
          setState(() {
            locale = Locale(value);
          });
        },
      ),
    );
  }
}

// ==========================================
// MAIN SCREEN - Bottom Navigation
// ==========================================

class MainScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;

  const MainScreen({super.key, required this.onLanguageChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      UserListPage(onLanguageChanged: widget.onLanguageChanged),
      const AdminListPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admins',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PAGE 1 - USER LIST
// ==========================================

class UserListPage extends StatefulWidget {
  final Function(String) onLanguageChanged;

  const UserListPage({super.key, required this.onLanguageChanged});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<dynamic>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = ApiService.getUsers();
  }

  void refreshData() {
    setState(() {
      futureUsers = ApiService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Tombol info lokasi file JSON
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Lokasi File JSON',
            onPressed: () async {
              final path = await ApiService.getJsonFilePath();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Penyimpanan File JSON'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data tersimpan di file JSON lokal:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          path,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Tombol reset data
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Data User',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Data User?'),
                  content: const Text(
                    'Apakah Anda yakin ingin mengembalikan data User ke daftar awal?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ApiService.resetToDefault();
                refreshData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data User berhasil di-reset'),
                    ),
                  );
                }
              }
            },
          ),

          // Tombol ganti bahasa
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'id',
                child: Text('Bahasa Indonesia'),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          ),
        ],
      ),

      // FAB - Test API User
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'user_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ApiTesterScreen(),
            ),
          ).then((_) => refreshData());
        },
        icon: const Icon(Icons.api),
        label: const Text('Test API User'),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: futureUsers,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 12),
                  Text(language.errorMessage),
                  ElevatedButton(
                    onPressed: refreshData,
                    child: Text(language.retry),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text(language.noData));
          }

          return RefreshIndicator(
            onRefresh: () async => refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        (user['name'] ?? 'U')[0],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailPage(userId: user['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// PAGE 2 - ADMIN LIST
// ==========================================

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  late Future<List<Admin>> futureAdmins;

  @override
  void initState() {
    super.initState();
    futureAdmins = AdminService.getAdmins();
  }

  void refreshData() {
    setState(() {
      futureAdmins = AdminService.getAdmins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Admin'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Tombol reset data Admin
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Data Admin',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Data Admin?'),
                  content: const Text(
                    'Apakah Anda yakin ingin mengembalikan data Admin ke daftar awal?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await AdminService.resetToDefault();
                refreshData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data Admin berhasil di-reset'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),

      // FAB - Cari Admin by ID
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_fab',
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          _showSearchAdminDialog(context);
        },
        icon: const Icon(Icons.search),
        label: const Text('Cari Admin'),
      ),

      body: FutureBuilder<List<Admin>>(
        future: futureAdmins,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: refreshData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final admins = snapshot.data ?? [];

          if (admins.isEmpty) {
            return const Center(child: Text('Tidak ada data Admin'));
          }

          return RefreshIndicator(
            onRefresh: () async => refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];

                // Highlight admin dengan ID NIM (912)
                final isNimAdmin = admin.id == AdminService.nimAdminId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isNimAdmin
                      ? Colors.deepPurple.shade50
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isNimAdmin
                          ? Colors.deepPurple
                          : Colors.deepPurple.shade100,
                      child: Text(
                        admin.name.isNotEmpty ? admin.name[0] : 'A',
                        style: TextStyle(
                          color: isNimAdmin
                              ? Colors.white
                              : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            admin.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isNimAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NIM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin.email),
                        Text(
                          'Dept: ${admin.department}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminDetailPage(adminId: admin.id),
                        ),
                      ).then((_) => refreshData());
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showSearchAdminDialog(BuildContext context) {
    final idController = TextEditingController(
      text: AdminService.nimAdminId.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cari Admin berdasarkan ID'),
        content: TextField(
          controller: idController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan ID Admin',
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final id = int.tryParse(idController.text);
              if (id != null) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminDetailPage(adminId: id),
                  ),
                ).then((_) => refreshData());
              }
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PAGE 3 - USER DETAIL
// ==========================================

class UserDetailPage extends StatefulWidget {
  final int userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late Future<dynamic> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = ApiService.getUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail User #${widget.userId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<dynamic>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          // Parse city dari address atau langsung
          String city = '';
          if (user['address'] != null && user['address'] is Map) {
            city = user['address']['city']?.toString() ?? '';
          } else if (user['city'] != null) {
            city = user['city'].toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    (user['name'] ?? 'U')[0],
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'USER',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info cards
                _buildInfoCard('ID', user['id'].toString(), Icons.numbers),
                _buildInfoCard('Nama', user['name'] ?? '', Icons.person),
                _buildInfoCard('Email', user['email'] ?? '', Icons.email),
                _buildInfoCard('Kota', city, Icons.location_city),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PAGE 4 - ADMIN DETAIL (dengan DELETE)
// ==========================================

class AdminDetailPage extends StatefulWidget {
  final int adminId;

  const AdminDetailPage({super.key, required this.adminId});

  @override
  State<AdminDetailPage> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<AdminDetailPage> {
  late Future<Admin> futureAdmin;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    futureAdmin = AdminService.getAdmin(widget.adminId);
  }

  Future<void> _deleteAdmin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Admin?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus Admin dengan ID ${widget.adminId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isDeleting = true);
      try {
        final success = await AdminService.deleteAdmin(widget.adminId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Admin berhasil dihapus' : 'Gagal menghapus Admin',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Admin #${widget.adminId}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Tombol hapus Admin
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Hapus Admin',
            onPressed: isDeleting ? null : _deleteAdmin,
          ),
        ],
      ),
      body: FutureBuilder<Admin>(
        future: futureAdmin,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final admin = snapshot.data;
          if (admin == null) {
            return const Center(child: Text('Admin tidak ditemukan'));
          }

          final isNimAdmin = admin.id == AdminService.nimAdminId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isNimAdmin
                      ? Colors.deepPurple
                      : Colors.deepPurple.shade100,
                  child: Text(
                    admin.name.isNotEmpty ? admin.name[0] : 'A',
                    style: TextStyle(
                      fontSize: 36,
                      color: isNimAdmin
                          ? Colors.white
                          : Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  admin.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isNimAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NIM: 20240801120',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Info cards
                _buildInfoCard(
                  'ID',
                  admin.id.toString(),
                  Icons.numbers,
                ),
                _buildInfoCard('Nama', admin.name, Icons.person),
                _buildInfoCard('Email', admin.email, Icons.email),
                _buildInfoCard(
                  'Department',
                  admin.department,
                  Icons.business,
                ),

                const SizedBox(height: 24),

                // Tombol hapus
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isDeleting ? null : _deleteAdmin,
                    icon: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete),
                    label: Text(
                      isDeleting
                          ? 'Menghapus...'
                          : 'Hapus Admin Ini',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PAGE 5 - API TESTER (User CRUD)
// ==========================================

class ApiTesterScreen extends StatefulWidget {
  final int? initialId;

  const ApiTesterScreen({super.key, this.initialId});

  @override
  State<ApiTesterScreen> createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {
  String selectedMethod = 'GET';

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;
  dynamic result;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialId != null) {
      idController.text = widget.initialId.toString();
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ==========================================
  // SEND REQUEST
  // ==========================================

  Future<void> sendRequest() async {
    final id = int.tryParse(idController.text);

    // Validasi ID (tidak diperlukan untuk POST)
    if (selectedMethod != 'POST' && id == null) {
      _showMessage('Masukkan ID pengguna yang valid');
      return;
    }

    // Validasi nama (untuk POST, PUT, PATCH)
    if (selectedMethod != 'GET' &&
        selectedMethod != 'DELETE' &&
        nameController.text.trim().isEmpty) {
      _showMessage('Nama tidak boleh kosong');
      return;
    }

    // Validasi email (untuk POST dan PUT)
    if ((selectedMethod == 'POST' || selectedMethod == 'PUT') &&
        emailController.text.trim().isEmpty) {
      _showMessage('Email tidak boleh kosong');
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
      errorMessage = null;
    });

    try {
      dynamic response;

      switch (selectedMethod) {
        // GET
        case 'GET':
          response = await ApiService.getUser(id!);
          break;

        // POST
        case 'POST':
          response = await ApiService.createUser(
            nameController.text.trim(),
            emailController.text.trim(),
          );
          break;

        // PUT
        case 'PUT':
          response = await ApiService.updateUser(
            id!,
            nameController.text.trim(),
            emailController.text.trim(),
          );
          break;

        // PATCH
        case 'PATCH':
          response = await ApiService.patchUser(
            id!,
            nameController.text.trim(),
          );
          break;

        // DELETE
        case 'DELETE':
          final success = await ApiService.deleteUser(id!);
          response = {
            'success': success,
            'message': success
                ? 'User dengan ID $id berhasil dihapus'
                : 'Gagal menghapus User dengan ID $id',
          };
          break;
      }

      setState(() {
        result = response;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isGet = selectedMethod == 'GET';
    final isPost = selectedMethod == 'POST';
    final isPut = selectedMethod == 'PUT';
    final isPatch = selectedMethod == 'PATCH';
    final isDelete = selectedMethod == 'DELETE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Method Tester'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              'Request Configuration',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih HTTP method dan masukkan data yang ingin dikirim.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // METHOD DROPDOWN
            const Text(
              'HTTP Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.api),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'GET',
                  child: Text('GET - Retrieve Data'),
                ),
                DropdownMenuItem(
                  value: 'POST',
                  child: Text('POST - Create Data'),
                ),
                DropdownMenuItem(
                  value: 'PUT',
                  child: Text('PUT - Replace Data'),
                ),
                DropdownMenuItem(
                  value: 'PATCH',
                  child: Text('PATCH - Update Data'),
                ),
                DropdownMenuItem(
                  value: 'DELETE',
                  child: Text('DELETE - Remove Data'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                  result = null;
                  errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 20),

            // ID INPUT
            if (!isPost) ...[
              const Text(
                'User ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Contoh: ${ApiService.nimUserId}',
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // NAME INPUT
            if (!isGet && !isDelete) ...[
              const Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nama pengguna',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // EMAIL INPUT
            if (isPost || isPut) ...[
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan email pengguna',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // INFORMATION BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGet
                    ? 'GET: Mengambil data pengguna berdasarkan ID.'
                    : isPost
                        ? 'POST: Mengirim data pengguna baru dengan ID ${ApiService.nimUserId} (NIM: 20240801120).'
                        : isPut
                            ? 'PUT: Mengganti nama dan email pengguna.'
                            : isPatch
                                ? 'PATCH: Memperbarui nama pengguna dengan menambahkan " - Flutter Developer".'
                                : 'DELETE: Mengirim permintaan penghapusan pengguna.',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            // SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : sendRequest,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isLoading ? 'Sending Request...' : 'Send Request',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // RESPONSE RESULT
            if (result != null || errorMessage != null) ...[
              const Text(
                'Response Result',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorMessage != null
                      ? Colors.red.withValues(alpha: 0.08)
                      : Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: errorMessage != null
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                child: SelectableText(
                  errorMessage ??
                      const JsonEncoder.withIndent('  ').convert(result),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
