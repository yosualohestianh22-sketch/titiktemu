import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TambahKulinerScreen extends StatefulWidget {
  const TambahKulinerScreen({super.key});

  @override
  State<TambahKulinerScreen> createState() => _TambahKulinerScreenState();
}

class _TambahKulinerScreenState extends State<TambahKulinerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _daerahController = TextEditingController();

  // Data rekomendasi tiruan (dummy data) berdasarkan daerah
  final Map<String, List<Map<String, String>>> _dataRekomendasi = {
    'purwokerto': [
      {
        'nama': 'Mendoan Kriuk',
        'deskripsi': 'Tempe mendoan hangat khas Banyumas.',
      },
      {'nama': 'Soto Sokaraja', 'deskripsi': 'Soto dengan bumbu kacang lezat.'},
      {'nama': 'Getuk Goreng', 'deskripsi': 'Manis gurih khas Sokaraja.'},
    ],
    'pemalang': [
      {
        'nama': 'Nasi Grombyang',
        'deskripsi': 'Kuliner kuah mirip soto daging sapi.',
      },
      {'nama': 'Sate Loso', 'deskripsi': 'Sate kerbau/sapi bumbu kacang khas.'},
    ],
    'jogja': [
      {
        'nama': 'Gudeg Wijilan',
        'deskripsi': 'Gudeg nangka muda manis legendaris.',
      },
      {
        'nama': 'Bakpia Pathok',
        'deskripsi': 'Kue isi kacang hijau khas Jogja.',
      },
    ],
    'yogyakarta': [
      {
        'nama': 'Gudeg Wijilan',
        'deskripsi': 'Gudeg nangka muda manis legendaris.',
      },
      {
        'nama': 'Bakpia Pathok',
        'deskripsi': 'Kue pia isi kacang hijau khas Jogja.',
      },
      {
        'nama': 'Sate Klatak',
        'deskripsi': 'Sate kambing muda yang dibakar menggunakan jeruji besi.',
      },
    ],
    'bali': [
      {
        'nama': 'Ayam Betutu',
        'deskripsi': 'Ayam kaya rempah yang dimasak perlahan.',
      },
      {
        'nama': 'Sate Lilit',
        'deskripsi': 'Sate daging cincang yang dililit di batang serai.',
      },
      {
        'nama': 'Nasi Jinggo',
        'deskripsi': 'Nasi bungkus porsi kecil dengan sambal pedas mantap.',
      },
    ],
    'jakarta': [
      {
        'nama': 'Kerak Telor',
        'deskripsi': 'Kuliner khas Betawi dari beras ketan dan telur.',
      },
      {
        'nama': 'Soto Betawi',
        'deskripsi': 'Soto daging dengan kuah santan dan susu yang gurih.',
      },
    ],
    'bandung': [
      {
        'nama': 'Siomay Bandung',
        'deskripsi': 'Siomay ikan dengan siraman bumbu kacang kental.',
      },
      {
        'nama': 'Batagor',
        'deskripsi': 'Bakso tahu goreng renyah khas Kota Kembang.',
      },
      {
        'nama': 'Mie Kocok',
        'deskripsi': 'Mie kuah kaldu sapi kental dengan kikil empuk.',
      },
    ],
    'lombok': [
      {
        'nama': 'Ayam Taliwang',
        'deskripsi': 'Ayam bakar bumbu pedas khas Lombok.',
      },
      {
        'nama': 'Plecing Kangkung',
        'deskripsi': 'Kangkung rebus disiram sambal tomat pedas segar.',
      },
    ],
    'labuan bajo': [
      {
        'nama': 'Ikan Kuah Asam',
        'deskripsi': 'Sup ikan segar dengan kuah asam belimbing wuluh.',
      },
      {
        'nama': 'Kolo (Nasi Bakar)',
        'deskripsi': 'Nasi yang dimasak di dalam bambu bakar.',
      },
    ],
    'borneo': [
      {
        'nama': 'Soto Banjar',
        'deskripsi': 'Soto ayam khas Kalimantan berkuah rempah harum.',
      },
      {
        'nama': 'Chai Kue',
        'deskripsi': 'Kudapan kukus gurih isi bengkuang atau kucai.',
      },
    ],
    'makassar': [
      {
        'nama': 'Coto Makassar',
        'deskripsi': 'Sup daging dan jeroan sapi berkuah rempah pekat.',
      },
      {
        'nama': 'Konro Bakar',
        'deskripsi': 'Iga sapi bakar dengan siraman bumbu kacang khas.',
      },
      {
        'nama': 'Pisang Epe',
        'deskripsi': 'Pisang bakar jepit disiram saus gula merah manis.',
      },
    ],
    'raja ampat': [
      {
        'nama': 'Papeda & Ikan Kuah Kuning',
        'deskripsi': 'Bubur sagu kenyal dipadu sup ikan bumbu kunyit.',
      },
    ],
  };

  List<Map<String, String>> _rekomendasiTersedia = [];

  // Fungsi untuk mengecek rekomendasi saat user mengetik daerah
  void _updateRekomendasi(String nilaiInput) {
    String keyword = nilaiInput.toLowerCase().trim();
    setState(() {
      if (_dataRekomendasi.containsKey(keyword)) {
        _rekomendasiTersedia = _dataRekomendasi[keyword]!;
      } else {
        _rekomendasiTersedia = []; // Kosongkan jika daerah tidak terdaftar
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _daerahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Kuliner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INPUT DAERAH ---
              TextFormField(
                controller: _daerahController,
                decoration: const InputDecoration(
                  labelText: 'Daerah / Kota',
                  hintText:
                      'Coba ketik: Jogja, jakarta, purwokerto, labuan bajio, dll',
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged:
                    _updateRekomendasi, // Deteksi ketikan user secara real-time
                validator: (value) =>
                    value!.isEmpty ? 'Daerah tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // --- INPUT NAMA KULINER ---
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tempat / Menu Kuliner',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // --- INPUT DESKRIPSI ---
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kuliner',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // --- BAGIAN REKOMENDASI OTOMATIS ---
              if (_rekomendasiTersedia.isNotEmpty) ...[
                const Text(
                  '💡 Rekomendasi Kuliner di Daerah Ini:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rekomendasiTersedia.length,
                  itemBuilder: (context, index) {
                    final item = _rekomendasiTersedia[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.fastfood,
                          color: Colors.orange,
                        ),
                        title: Text(
                          item['nama']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item['deskripsi']!),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        onTap: () {
                          // Jika rekomendasi diklik, otomatis mengisi form di atas
                          setState(() {
                            _namaController.text = item['nama']!;
                            _deskripsiController.text = item['deskripsi']!;
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kuliner berhasil ditambahkan! 🎉'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Kuliner',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
