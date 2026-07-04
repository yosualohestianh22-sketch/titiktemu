import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TambahKulinerScreen extends StatefulWidget {
  // Hapus tanda required agar dari home_screen tidak wajib mengirim ID
  final String? itineraryId;

  const TambahKulinerScreen({super.key, this.itineraryId});

  @override
  State<TambahKulinerScreen> createState() => _TambahKulinerScreenState();
}

class _TambahKulinerScreenState extends State<TambahKulinerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _daerahController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _daerahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kuliner Daerah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kuliner',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama kuliner wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kuliner',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _daerahController,
                decoration: const InputDecoration(
                  labelText: 'Daerah / Asal',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Daerah wajib diisi'
                    : null,
              ),
              const SizedBox(height: 24),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Menampilkan loading indikator saat proses simpan ke Firebase
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // Menyimpan data ke koleksi 'kuliner'
                        await FirebaseFirestore.instance.collection('kuliner').add({
                          // Jika itineraryId kosong (karena dibuka dari home), beri kode umum 'GLOBAL_TRIP'
                          // atau ID default kelompok Anda agar tetap masuk ke database yang sama
                          'itinerary_id': widget.itineraryId ?? 'GLOBAL_TRIP',
                          'daerah': _daerahController.text.trim(),
                          'nama_kuliner': _namaController.text.trim(),
                          'deskripsi': _deskripsiController.text.trim(),
                          'created_at': Timestamp.now(),
                        });

                        // Menutup dialog loading
                        if (context.mounted) Navigator.pop(context);

                        // Menutup halaman input/dialog input kuliner dan kembali ke halaman detail
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Rekomendasi kuliner berhasil disimpan! 🎉',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        // Menutup loading jika error
                        if (context.mounted) Navigator.pop(context);

                        debugPrint("Gagal menyimpan ke Firebase: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyimpan data: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
