import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String nama;
  final String nim;
  final String hobi;
  final int skorAktivitas;

  const ProfileCard({
    super.key,
    required this.nama,
    required this.nim,
    required this.hobi,
    required this.skorAktivitas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330.0,
      padding: const EdgeInsets.all(20.0),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12.0),

        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // HEADER KARTU
          Row(
            children: [
              // LOGO FLUTTER
              Container(
                width: 60.0,
                height: 60.0,

                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),

                child: const Center(
                  child: FlutterLogo(
                    size: 60.0,
                  ),
                ),
              ),

              // JARAK PEMISAH
              const SizedBox(
                width: 15.0,
              ),

              // JUDUL DAN NAMA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kartu Praktikan',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 5.0,
                    ),

                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // PEMISAH
          const Divider(
            thickness: 1.5,
          ),

          // DETAIL IDENTITAS
          Text(
            'NIM: $nim',
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8.0,
          ),

          Text(
            'Hobi: $hobi',
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8.0,
          ),

          Text(
            'Skor Aktivitas: $skorAktivitas',
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}