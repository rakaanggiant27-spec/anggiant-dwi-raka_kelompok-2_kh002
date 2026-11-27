
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/app_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Profile Card',
      theme: AppTheme.theme,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const double d = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Profile Card'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 + d),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8 + d),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40 + (2 * d),
                      height: 40 + (2 * d),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade100,
                      ),
                      child: const Icon(
                        Icons.person,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anggiant Dwi Raka'),
                          SizedBox(height: 8),
                          Text('20240801120'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Program Studi: Teknik Informatika'),
                const SizedBox(height: 8),
                const Text(
                  'Nama saya Anggiant Dwi Raka, Saya kuliah di '
                      'Universitas Esa Unggul Kota Bekasi, '
                      'Saya Sekarang Semester 5',
                ),
                const SizedBox(height: 16),
                const AppButton(
                  label: 'Kunjungi GitHub Saya',
                  icon: Icons.open_in_new,
                  url: 'https://github.com/rakaanggiant27-spec?tab=repositories',
                  height: 40,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
