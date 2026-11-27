
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatatan Stok Barang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StokBarangPage(),
    );
  }
}

class StokBarangPage extends StatefulWidget {
  const StokBarangPage({super.key});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _tanggalMasukController = TextEditingController();
  final _tanggalKeluarController = TextEditingController();
  final _kodeController = TextEditingController();
  final _stokController = TextEditingController();

  bool _isLoading = false;

  Future<void> _simpanBarang() async {
    if (!_formKey.currentState!.validate()) return;

    final namaBarang = _namaController.text.trim();
    final tanggalMasuk = _tanggalMasukController.text.trim();
    final tanggalKeluar = _tanggalKeluarController.text.trim();
    final kodeBarang = int.tryParse(_kodeController.text.trim());
    final jumlahStok = int.tryParse(_stokController.text.trim());

    if (kodeBarang == null || jumlahStok == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('stok_barang').add({
        'nama_barang': namaBarang,
        'tanggal_masuk': tanggalMasuk,
        'tanggal_keluar': tanggalKeluar,
        'kode_barang': kodeBarang,
        'jumlah_stok': jumlahStok,
        'waktu': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _namaController.clear();
      _tanggalMasukController.clear();
      _tanggalKeluarController.clear();
      _kodeController.clear();
      _stokController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan barang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalMasukController.dispose();
    _tanggalKeluarController.dispose();
    _kodeController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Stok Barang'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.inventory_2,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),

              _field(
                controller: _namaController,
                label: 'Nama Barang',
                icon: Icons.inventory,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),

              _field(
                controller: _tanggalMasukController,
                label: 'Tanggal Masuk Barang',
                icon: Icons.calendar_today,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),

              _field(
                controller: _tanggalKeluarController,
                label: 'Tanggal Keluar Barang',
                icon: Icons.event,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),

              _field(
                controller: _kodeController,
                label: 'Kode Barang (minimal 6 digit, akhiran 20)',
                icon: Icons.qr_code,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode barang wajib diisi';
                  }

                  final kode = value.trim();

                  if (!RegExp(r'^[0-9]+$').hasMatch(kode)) {
                    return 'Kode barang harus berupa angka';
                  }

                  if (kode.length < 6) {
                    return 'Kode barang minimal 6 digit';
                  }

                  if (!kode.endsWith('20')) {
                    return 'Kode barang harus diakhiri 20';
                  }

                  if (int.tryParse(kode) == null) {
                    return 'Kode barang tidak valid';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              _field(
                controller: _stokController,
                label: 'Jumlah Stok',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah stok wajib diisi';
                  }

                  final stok = int.tryParse(value.trim());

                  if (stok == null) {
                    return 'Stok harus berupa bilangan bulat';
                  }

                  if (stok < 0) {
                    return 'Stok tidak boleh negatif';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _simpanBarang,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan Barang',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
