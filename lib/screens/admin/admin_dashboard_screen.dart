import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/data/mock_places.dart';
import 'package:titik_temu/data/mock_hotels.dart';
import 'package:titik_temu/models/place_model.dart';
import 'package:titik_temu/screens/auth/login_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:titik_temu/screens/admin/map_location_picker_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCity = 'Yogyakarta';

  // Daftar kota unik untuk filter
  final List<String> _cities = [
    'Yogyakarta',
    'Bali',
    'Jakarta',
    'Bandung',
    'Lombok',
    'Surabaya',
    'Labuan Bajo',
    'Borneo',
    'Makassar',
    'Raja Ampat'
  ];



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  bool _isDialogOpen = false;

  InputDecoration _buildInputDecoration(String label, Color focusColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
    );
  }

  Future<void> _pickAndUploadImage(TextEditingController controller, String folderName) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      
      if (image == null) return;
      
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            color: Color(0xFF1E293B),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                  SizedBox(height: 16),
                  Text('Mengunggah gambar...', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
        ),
      );

      final imageBytes = await image.readAsBytes();
      final fileName = '${folderName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      if (mounted) Navigator.pop(context);

      controller.text = publicUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil diunggah!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
      }
    }
  }

  void _openMapPicker(
    String city,
    TextEditingController latController,
    TextEditingController lngController,
    Color focusColor,
  ) async {
    final double? existingLat = double.tryParse(latController.text.trim());
    final double? existingLng = double.tryParse(lngController.text.trim());
    LatLng? initialLoc;
    
    if (existingLat != null && existingLng != null && existingLat != 0.0 && existingLng != 0.0) {
      initialLoc = LatLng(existingLat, existingLng);
    }

    if (!mounted) return;
    
    setState(() => _isDialogOpen = true);

    final LatLng? result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          city: city,
          initialLocation: initialLoc,
        ),
      ),
    );

    if (result != null) {
      latController.text = result.latitude.toStringAsFixed(6);
      lngController.text = result.longitude.toStringAsFixed(6);
    }
    
    setState(() => _isDialogOpen = false);
  }

  // --- CRUD DESTINASI WISATA ---
  void _showAddEditPlaceDialog({PlaceModel? place}) {
    final isEdit = place != null;
    final nameController = TextEditingController(text: place?.name ?? '');
    final descController = TextEditingController(text: place?.description ?? '');
    final priceController = TextEditingController(text: place?.price.toString() ?? '0');
    final latController = TextEditingController(text: place?.latitude.toString() ?? '-7.7956');
    final lngController = TextEditingController(text: place?.longitude.toString() ?? '110.3695');
    final imageController = TextEditingController(text: place?.imageUrl ?? 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400');
    String selectedCategory = place?.category ?? 'Alam';
    String selectedCityVal = place?.city ?? _selectedCity;

    setState(() => _isDialogOpen = true);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text(
                isEdit ? 'Edit Destinasi Wisata' : 'Tambah Wisata Baru',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCityVal,
                      dropdownColor: const Color(0xFF1E293B),
                      decoration: _buildInputDecoration('Kota', const Color(0xFF6A1B9A)),
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      items: _cities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedCityVal = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      decoration: _buildInputDecoration('Nama Wisata', const Color(0xFF6A1B9A)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: const Color(0xFF1E293B),
                      decoration: _buildInputDecoration('Kategori', const Color(0xFF6A1B9A)),
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      items: ['Alam', 'Sejarah', 'Belanja', 'Religi', 'Kuliner', 'Hiburan', 'Petualangan'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      decoration: _buildInputDecoration('Deskripsi singkat', const Color(0xFF6A1B9A)),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Harga Tiket (Rp)', const Color(0xFF6A1B9A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Latitude', const Color(0xFF6A1B9A)).copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.map_outlined, color: Colors.white70),
                                tooltip: 'Pilih di Peta',
                                onPressed: () => _openMapPicker(selectedCityVal, latController, lngController, const Color(0xFF6A1B9A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: lngController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Longitude', const Color(0xFF6A1B9A)).copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.map_outlined, color: Colors.white70),
                                tooltip: 'Pilih di Peta',
                                onPressed: () => _openMapPicker(selectedCityVal, latController, lngController, const Color(0xFF6A1B9A)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      decoration: _buildInputDecoration('URL Gambar (Unsplash / Upload)', const Color(0xFF6A1B9A)).copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white70),
                          tooltip: 'Unggah Gambar dari Perangkat',
                          onPressed: () => _pickAndUploadImage(imageController, 'place'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.white60, fontFamily: 'Poppins')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();
                    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                    final lat = double.tryParse(latController.text.trim()) ?? 0.0;
                    final lng = double.tryParse(lngController.text.trim()) ?? 0.0;
                    final img = imageController.text.trim();

                    if (name.isEmpty) return;

                    setState(() {
                      if (isEdit) {
                        final index = mockPlaces.indexOf(place);
                        if (index != -1) {
                          mockPlaces[index] = PlaceModel(
                            id: place.id,
                            name: name,
                            city: selectedCityVal,
                            category: selectedCategory,
                            description: desc,
                            latitude: lat,
                            longitude: lng,
                            price: price,
                            imageUrl: img,
                          );
                        }
                      } else {
                        final newId = 'yog_${DateTime.now().millisecondsSinceEpoch}';
                        mockPlaces.insert(
                          0,
                          PlaceModel(
                            id: newId,
                            name: name,
                            city: selectedCityVal,
                            category: selectedCategory,
                            description: desc,
                            latitude: lat,
                            longitude: lng,
                            price: price,
                            imageUrl: img,
                          ),
                        );
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Berhasil mengedit destinasi!' : 'Berhasil menambah destinasi baru!',
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isEdit ? 'Simpan' : 'Tambah',
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() => _isDialogOpen = false);
    });
  }

  // --- CRUD REKOMENDASI HOTEL ---
  void _showAddEditHotelDialog({MockHotelModel? hotel}) {
    final isEdit = hotel != null;
    final nameController = TextEditingController(text: hotel?.name ?? '');
    final addressController = TextEditingController(text: hotel?.address ?? '');
    final priceController = TextEditingController(text: hotel?.pricePerNight.toString() ?? '500000');
    final ratingController = TextEditingController(text: hotel?.rating.toString() ?? '4.5');
    final latController = TextEditingController(text: hotel?.latitude.toString() ?? '-7.7956');
    final lngController = TextEditingController(text: hotel?.longitude.toString() ?? '110.3695');
    final imageController = TextEditingController(text: hotel?.imageUrl ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500');
    String selectedCityVal = hotel?.city ?? _selectedCity;

    setState(() => _isDialogOpen = true);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text(
                isEdit ? 'Edit Rekomendasi Hotel' : 'Tambah Hotel Baru',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCityVal,
                      dropdownColor: const Color(0xFF1E293B),
                      decoration: _buildInputDecoration('Kota', const Color(0xFF02A2E6)),
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      items: _cities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedCityVal = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      decoration: _buildInputDecoration('Nama Hotel', const Color(0xFF02A2E6)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      decoration: _buildInputDecoration('Alamat Hotel', const Color(0xFF02A2E6)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Sewa per Malam (Rp)', const Color(0xFF02A2E6)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ratingController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Rating (1.0 - 5.0)', const Color(0xFF02A2E6)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Latitude', const Color(0xFF02A2E6)).copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.map_outlined, color: Colors.white70),
                                tooltip: 'Pilih di Peta',
                                onPressed: () => _openMapPicker(selectedCityVal, latController, lngController, const Color(0xFF02A2E6)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: lngController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Longitude', const Color(0xFF02A2E6)).copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.map_outlined, color: Colors.white70),
                                tooltip: 'Pilih di Peta',
                                onPressed: () => _openMapPicker(selectedCityVal, latController, lngController, const Color(0xFF02A2E6)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      decoration: _buildInputDecoration('URL Gambar Hotel (Upload)', const Color(0xFF02A2E6)).copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white70),
                          tooltip: 'Unggah Gambar dari Perangkat',
                          onPressed: () => _pickAndUploadImage(imageController, 'hotel'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.white60, fontFamily: 'Poppins')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02A2E6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final address = addressController.text.trim();
                    final price = double.tryParse(priceController.text.trim()) ?? 500000.0;
                    final rat = double.tryParse(ratingController.text.trim()) ?? 4.5;
                    final lat = double.tryParse(latController.text.trim()) ?? 0.0;
                    final lng = double.tryParse(lngController.text.trim()) ?? 0.0;
                    final img = imageController.text.trim();

                    if (name.isEmpty) return;

                    setState(() {
                      if (isEdit) {
                        final index = mockHotels.indexOf(hotel);
                        if (index != -1) {
                          mockHotels[index] = MockHotelModel(
                            name: name,
                            city: selectedCityVal,
                            latitude: lat,
                            longitude: lng,
                            pricePerNight: price,
                            rating: rat,
                            imageUrl: img,
                            address: address,
                          );
                        }
                      } else {
                        mockHotels.insert(
                          0,
                          MockHotelModel(
                            name: name,
                            city: selectedCityVal,
                            latitude: lat,
                            longitude: lng,
                            pricePerNight: price,
                            rating: rat,
                            imageUrl: img,
                            address: address,
                          ),
                        );
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Berhasil mengedit rekomendasi hotel!' : 'Berhasil menambah hotel baru!',
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isEdit ? 'Simpan' : 'Tambah',
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() => _isDialogOpen = false);
    });
  }

  // --- RENDERING TABS ---

  Widget _buildWisataTab() {
    final filteredPlaces = mockPlaces.where((p) => p.city.toLowerCase() == _selectedCity.toLowerCase()).toList();

    return Column(
      children: [
        _buildCityFilter(),
        Expanded(
          child: filteredPlaces.isEmpty
              ? const Center(child: Text('Tidak ada destinasi wisata.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            place.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: Colors.grey[800],
                              width: 60,
                              height: 60,
                              child: const Icon(Icons.broken_image, color: Colors.white60),
                            ),
                          ),
                        ),
                        title: Text(place.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        subtitle: Text(
                          '${place.category} • Rp ${place.price}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _showAddEditPlaceDialog(place: place),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  mockPlaces.remove(place);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Berhasil menghapus wisata')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHotelTab() {
    final filteredHotels = mockHotels.where((h) => h.city.toLowerCase() == _selectedCity.toLowerCase()).toList();

    return Column(
      children: [
        _buildCityFilter(),
        Expanded(
          child: filteredHotels.isEmpty
              ? const Center(child: Text('Tidak ada hotel terdaftar.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredHotels.length,
                  itemBuilder: (context, index) {
                    final hotel = filteredHotels[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            hotel.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: Colors.grey[800],
                              width: 60,
                              height: 60,
                              child: const Icon(Icons.broken_image, color: Colors.white60),
                            ),
                          ),
                        ),
                        title: Text(hotel.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        subtitle: Text(
                          '⭐ ${hotel.rating} • Rp ${hotel.pricePerNight.toInt()}/malam',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _showAddEditHotelDialog(hotel: hotel),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  mockHotels.remove(hotel);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Berhasil menghapus hotel')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada user terdaftar.', style: TextStyle(color: Colors.white70)));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            final name = userData['name'] ?? 'No Name';
            final email = userData['email'] ?? 'No Email';
            final role = userData['role'] ?? 'user';
            final status = userData['status'] ?? 'Aktif';
            final bool isBlocked = status == 'Diblokir';

            return Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: role == 'admin' ? Colors.redAccent : Colors.purpleAccent,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                subtitle: Text(
                  '$email • Role: ${role.toString().toUpperCase()}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: role == 'admin'
                    ? const Chip(label: Text('ADMIN', style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.red)
                    : TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: isBlocked ? Colors.green : Colors.redAccent,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('users').doc(userDoc.id).update({
                            'status': isBlocked ? 'Aktif' : 'Diblokir',
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Status user $name diubah menjadi ${isBlocked ? 'Aktif' : 'Diblokir'}')),
                          );
                        },
                        child: Text(isBlocked ? 'Aktifkan' : 'Blokir'),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCityFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = city == _selectedCity;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(city, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontFamily: 'Poppins')),
              selected: isSelected,
              selectedColor: const Color(0xFF6A1B9A),
              backgroundColor: const Color(0xFF1E293B),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCity = city;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate premium theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Panel Operator TitikTemu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6A1B9A),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.map_outlined), text: 'Data Wisata'),
            Tab(icon: Icon(Icons.hotel_outlined), text: 'Data Hotel'),
            Tab(icon: Icon(Icons.people_outline), text: 'Kelola User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWisataTab(),
          _buildHotelTab(),
          _buildUserTab(),
        ],
      ),
      floatingActionButton: _isDialogOpen
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF6A1B9A),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                if (_tabController.index == 0) {
                  _showAddEditPlaceDialog();
                } else if (_tabController.index == 1) {
                  _showAddEditHotelDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pendaftaran user baru dapat dilakukan melalui halaman registrasi utama.')),
                  );
                }
              },
            ),
    );
  }
}
