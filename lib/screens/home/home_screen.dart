import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titik_temu/models/itinerary_model.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/providers/itinerary_provider.dart';
import 'package:titik_temu/screens/itinerary/create_itinerary_screen.dart';
import 'package:titik_temu/screens/itinerary/itinerary_detail_screen.dart';
import 'package:titik_temu/screens/history/history_screen.dart';
import 'package:titik_temu/screens/profile/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:titik_temu/screens/itinerary/tambah_kuliner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final itineraryProvider = context.read<ItineraryProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'TitikTemu',
          style: TextStyle(
            color: isDark
                ? Theme.of(context).primaryColor
                : const Color(0xFF6A1B9A),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                radius: 20,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(
                        Icons.person,
                        color: isDark
                            ? Theme.of(context).primaryColor
                            : const Color(0xFF6A1B9A),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Section: Greeting ---
            Text(
              'Halo, ${user?.displayName?.split(' ').first ?? 'Traveler'}! 👋',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mau jalan-jalan ke mana hari ini?',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // --- Section: Kartu Utama (Call to Action) ---
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8E2DE2),
                    Color(0xFF4A00E0),
                  ], // Gradien modern ungu biru
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF4A00E0,
                    ).withValues(alpha: isDark ? 0.5 : 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateItineraryScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.explore_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Buat Itinerary Otomatis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Biar kami yang merekomendasikan rute terbaik\nuntuk liburanmu selanjutnya!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showJoinTripDialog(context),
                    icon: const Icon(Icons.group_add_rounded),
                    label: const Text('Gabung via Kode'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF6A1B9A),
                      side: BorderSide(
                        color: isDark
                            ? Theme.of(context).primaryColor
                            : const Color(0xFF6A1B9A),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Jarak antar tombol
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigasi ke halaman tambah kuliner tanpa mengoper ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TambahKulinerScreen(), // KODE YANG SUDAH DIPERBAIKI
                        ),
                      );
                    },
                    icon: const Icon(Icons.restaurant_rounded),
                    label: const Text('Rekomendasi Kuliner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- Section: Header Riwayat ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Perjalanan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    // Navigasi ke halaman tambah kuliner tanpa mengoper ID di sini
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TambahKulinerScreen(), // Kembalikan seperti ini
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? Theme.of(context).primaryColor
                        : const Color(0xFF6A1B9A),
                  ),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Section: List Riwayat ---
            if (user != null)
              StreamBuilder<List<ItineraryModel>>(
                stream: itineraryProvider.getUserItinerariesStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final itineraries = snapshot.data;

                  if (itineraries == null || itineraries.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flight_takeoff_rounded,
                            size: 64,
                            color: isDark ? Colors.grey[750] : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada perjalanan.\nYuk mulai rencanakan sekarang!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Batasi hanya menampilkan 3 item terbaru di Beranda
                  final displayCount = itineraries.length > 3
                      ? 3
                      : itineraries.length;

                  // Tampilkan daftar perjalanan
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayCount,
                    itemBuilder: (context, index) {
                      final ItineraryModel itinerary = itineraries[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[850]!
                                : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.15 : 0.03,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ItineraryDetailScreen(
                                    itinerary: itinerary,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Ikon Kota
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Theme.of(context).primaryColor
                                                .withValues(alpha: 0.15)
                                          : const Color(
                                              0xFFF3E5F5,
                                            ), // Ungu sangat muda
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.location_city_rounded,
                                      color: isDark
                                          ? Theme.of(context).primaryColor
                                          : const Color(0xFF8E2DE2),
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Detail Teks
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                itinerary.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (itinerary.isCompleted) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.green,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Colors.green,
                                                      size: 10,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Selesai',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${itinerary.city} • ${DateFormat('dd MMM').format(itinerary.startDate)} - ${DateFormat('dd MMM').format(itinerary.endDate)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Ikon Panah
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey[400],
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showJoinTripDialog(BuildContext context) {
    final codeController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    final itineraryProvider = context.read<ItineraryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(Icons.group_add_rounded, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    'Gabung Perjalanan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Masukkan 6-digit kode undangan dari teman Anda untuk berkolaborasi dalam rencana perjalanan mereka.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    autofocus: true,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'CONTOH',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        letterSpacing: 4.0,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: themePrimary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: itineraryProvider.isLoading
                      ? null
                      : () async {
                          final code = codeController.text.trim();
                          final user = authProvider.currentUser;
                          if (code.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kode harus terdiri dari 6 karakter',
                                ),
                              ),
                            );
                            return;
                          }
                          if (user == null) return;

                          setDialogState(() {});

                          final tripTitle = await itineraryProvider
                              .joinItineraryWithCode(code, user.uid);

                          if (context.mounted) {
                            if (tripTitle != null) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Berhasil bergabung ke perjalanan "$tripTitle"! 🎉',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setDialogState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(itineraryProvider.errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themePrimary,
                    foregroundColor: isDark
                        ? Colors.deepPurple[900]
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: itineraryProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Gabung'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
