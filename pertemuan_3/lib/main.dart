import 'package:flutter/material.dart';
import 'Profile_Card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Tugas Layout Flutter',

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.amber[100],
        useMaterial3: true,
      ),

      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ProfileCard(
          nama: 'Anggiant Dwi Raka',
          nim: '20240801120',
          hobi: 'Berenang',
          skorAktivitas: 70,
        ),
      ),
    );
  }
}