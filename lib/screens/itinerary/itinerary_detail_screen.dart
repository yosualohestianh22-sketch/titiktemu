import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../models/itinerary_model.dart';
import '../../models/itinerary_item_model.dart';
import '../../providers/itinerary_provider.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final ItineraryModel itinerary;

  const ItineraryDetailScreen({super.key, required this.itinerary});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  final bool _showMockMap = false;
  StreamSubscription<ItineraryModel>? _itinerarySubscription;
  List<String> _previousSharedWith = [];

  @override
  void initState() {
    super.initState();
    _previousSharedWith = List<String>.from(widget.itinerary.sharedWith);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itinerarySubscription = context
          .read<ItineraryProvider>()
          .getItineraryStream(widget.itinerary.id)
          .listen((itinerary) {
            final currentSharedWith = itinerary.sharedWith;
            if (currentSharedWith.length > _previousSharedWith.length) {
              final joinedUids = currentSharedWith
                  .where((uid) => !_previousSharedWith.contains(uid))
                  .toList();
              if (joinedUids.isNotEmpty) {
                _showJoinNotification(joinedUids);
              }
            }
            _previousSharedWith = List<String>.from(currentSharedWith);
          });
    });
  }

  @override
  void dispose() {
    _itinerarySubscription?.cancel();
    super.dispose();
  }

  Future<void> _showJoinNotification(List<String> uids) async {
    for (final uid in uids) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists && mounted) {
          final userData = userDoc.data();
          final name = userData?['name'] ?? 'Rekan Baru';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.people_alt_rounded, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$name baru saja bergabung ke perjalanan ini! 🗺️',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).cardColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error showing join notification: $e');
      }
    }
  }

  static const Map<String, LatLng> _cityCoordinates = {
    'jakarta': LatLng(-6.2088, 106.8456),
    'bali': LatLng(-8.4095, 115.1889),
    'yogyakarta': LatLng(-7.7956, 110.3695),
    'bandung': LatLng(-6.9175, 107.6191),
    'surabaya': LatLng(-7.2575, 112.7521),
    'medan': LatLng(3.5952, 98.6722),
    'makassar': LatLng(-5.1477, 119.4327),
    'lombok': LatLng(-8.6529, 116.3249),
  };

  LatLng _getTargetCoordinates() {
    final cityName = widget.itinerary.city.toLowerCase().trim();
    for (final key in _cityCoordinates.keys) {
      if (cityName.contains(key)) {
        return _cityCoordinates[key]!;
      }
    }
    return const LatLng(-0.7893, 113.9213);
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  int get _tripDays {
    return widget.itinerary.endDate
            .difference(widget.itinerary.startDate)
            .inDays +
        1;
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse('http://maps.google.com/?q=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  Future<void> _toggleDayCompletion(ItineraryModel itinerary, int day) async {
    final List<int> currentCompleted = List<int>.from(itinerary.completedDays);
    if (currentCompleted.contains(day)) {
      currentCompleted.remove(day);
    } else {
      currentCompleted.add(day);
    }

    final totalDays =
        itinerary.endDate.difference(itinerary.startDate).inDays + 1;
    final bool allDone = currentCompleted.length == totalDays;

    final provider = context.read<ItineraryProvider>();
    await provider.updateItinerary(itinerary.id, {
      'completedDays': currentCompleted,
      'isCompleted': allDone,
    });
  }

  Future<void> _toggleTripCompletion(ItineraryModel itinerary) async {
    final provider = context.read<ItineraryProvider>();
    final bool newStatus = !itinerary.isCompleted;

    List<int> completed;
    if (newStatus) {
      final totalDays =
          itinerary.endDate.difference(itinerary.startDate).inDays + 1;
      completed = List<int>.generate(totalDays, (i) => i + 1);
    } else {
      completed = [];
    }

    await provider.updateItinerary(itinerary.id, {
      'completedDays': completed,
      'isCompleted': newStatus,
    });
  }

  void _showPlaceDetails(BuildContext context, dynamic placeItem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  placeItem.place.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                placeItem.place.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    size: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    placeItem.place.category,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: themePrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      placeItem.place.price == 0
                          ? 'Gratis'
                          : _formatNumber(placeItem.place.price),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                placeItem.place.description,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openGoogleMaps(
                      placeItem.place.latitude,
                      placeItem.place.longitude,
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigasi ke Lokasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themePrimary,
                    foregroundColor: isDark
                        ? Colors.deepPurple[900]
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openFullRouteInGoogleMaps() async {
    final places = widget.itinerary.places;
    if (places.isEmpty) return;

    if (places.length == 1) {
      _openGoogleMaps(
        places.first.place.latitude,
        places.first.place.longitude,
      );
      return;
    }

    final origin =
        '${places.first.place.latitude},${places.first.place.longitude}';
    final destination =
        '${places.last.place.latitude},${places.last.place.longitude}';

    String waypoints = '';
    if (places.length > 2) {
      final intermediatePlaces = places.sublist(1, places.length - 1);
      waypoints = intermediatePlaces
          .map((item) => '${item.place.latitude},${item.place.longitude}')
          .join('|');
    }

    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination${waypoints.isNotEmpty ? '&waypoints=$waypoints' : ''}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka rute di Google Maps'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContextcontext) {
    final itineraryProvider = context.watch<ItineraryProvider>();

    return StreamBuilder<ItineraryModel>(
      stream: itineraryProvider.getItineraryStream(widget.itinerary.id),
      initialData: widget.itinerary,
      builder: (context, snapshot) {
        final itinerary = snapshot.data ?? widget.itinerary;
        final targetLatLng = _getTargetCoordinates();
        final budgetFormatted = _formatNumber(itinerary.budget);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themePrimary = Theme.of(context).primaryColor;

        final List<LatLng> routePoints = itinerary.places
            .map((item) => LatLng(item.place.latitude, item.place.longitude))
            .toList();

        final List<Marker> placeMarkers = routePoints.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final point = entry.value;
          final place = itinerary.places[index];
          return Marker(
            point: point,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPlaceDetails(context, place),
              child: Container(
                decoration: BoxDecoration(
                  color: themePrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isDark ? Colors.deepPurple[900] : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList();

        if (itinerary.hotelLatitude != null &&
            itinerary.hotelLongitude != null) {
          final hotelLatLng = LatLng(
            itinerary.hotelLatitude!,
            itinerary.hotelLongitude!,
          );
          placeMarkers.add(
            Marker(
              point: hotelLatLng,
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🏨 Hotel: ${itinerary.hotelName} (${_formatNumber(itinerary.hotelPrice ?? 0)} / malam)',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hotel_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );

          routePoints.add(hotelLatLng);
        }

        CameraFit? cameraFit;
        if (routePoints.isNotEmpty) {
          final bounds = LatLngBounds.fromPoints(routePoints);
          cameraFit = CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(60.0),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).cardColor.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: itineraryProvider.getCollaboratorsProfilesStream(
                      itinerary.sharedWith,
                    ),
                    builder: (context, snapshot) {
                      final profiles = snapshot.data ?? [];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _buildCollaboratorsBar(profiles),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      _showMockMap
                          ? _buildMockMap(targetLatLng, themePrimary)
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: routePoints.isNotEmpty
                                    ? routePoints.first
                                    : targetLatLng,
                                initialZoom: 12.0,
                                initialCameraFit: cameraFit,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.titik_temu',
                                ),
                                if (routePoints.isNotEmpty)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: routePoints,
                                        color: themePrimary.withValues(
                                          alpha: 0.8,
                                        ),
                                        strokeWidth: 4.0,
                                        pattern: StrokePattern.dashed(
                                          segments: const [10, 10],
                                        ),
                                      ),
                                    ],
                                  ),
                                MarkerLayer(
                                  markers: routePoints.isNotEmpty
                                      ? placeMarkers
                                      : [
                                          Marker(
                                            point: targetLatLng,
                                            width: 60,
                                            height: 60,
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                ),
                              ],
                            ),
                      Positioned(
                        top: 50,
                        right: 16,
                        child: FloatingActionButton.small(
                          backgroundColor: Theme.of(context).cardColor,
                          tooltip: 'Buka Rute di Google Maps',
                          onPressed: _openFullRouteInGoogleMaps,
                          child: Icon(
                            Icons.satellite_alt_rounded,
                            color: themePrimary,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black38,
                                Colors.black87,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Kota Tujuan',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${itinerary.city} • ${itinerary.title}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          color: Theme.of(context).cardColor,
                          shadowColor: themePrimary.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  Icons.calendar_month_rounded,
                                  'Tanggal',
                                  '${_formatDate(itinerary.startDate)} - ${_formatDate(itinerary.endDate)}',
                                  themePrimary,
                                ),
                                Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                _buildInfoRow(
                                  Icons.timelapse_rounded,
                                  'Durasi',
                                  '$_tripDays Hari Perjalanan',
                                  themePrimary,
                                ),
                                Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                _buildInfoRow(
                                  Icons.people_alt_rounded,
                                  'Jumlah Anggota',
                                  '${itinerary.travelersCount} Orang',
                                  themePrimary,
                                ),
                                Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                _buildInfoRow(
                                  Icons.account_balance_wallet_rounded,
                                  'Maksimal Anggaran',
                                  budgetFormatted,
                                  themePrimary,
                                ),
                                if (itinerary.hotelName != null) ...[
                                  Divider(
                                    height: 24,
                                    thickness: 1,
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                  ),
                                  _buildInfoRow(
                                    Icons.hotel_rounded,
                                    'Penginapan (Hotel)',
                                    '${itinerary.hotelName} (${_formatNumber(itinerary.hotelPrice ?? 0)} / malam)',
                                    themePrimary,
                                  ),
                                ],
                                Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                _buildInviteCodeRow(
                                  context,
                                  itinerary.inviteCode,
                                  themePrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. Rute Perjalanan (Daftar Wisata)
                        const Text(
                          'Rute Perjalanan & Lokasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPlacesList(itinerary.places, itinerary),

                        const SizedBox(height: 32),

                        // === 2. FITUR BARU: DAFTAR RENCANA KULINER (DI SINI TEMPATNYA) ===
                        const Text(
                          '🍽️ Rencana Kuliner Pilihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('kuliner')
                              .where(
                                'itinerary_id',
                                isEqualTo: itinerary.id,
                              ) // Filter berdasarkan ID perjalanan saat ini
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[850]!
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  'Belum ada rekomendasi kuliner yang disimpan untuk perjalanan ini.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            final listKuliner = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listKuliner.length,
                              itemBuilder: (context, index) {
                                final data =
                                    listKuliner[index].data()
                                        as Map<String, dynamic>;
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  elevation: 2,
                                  color: Theme.of(context).cardColor,
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.amber,
                                      child: Icon(
                                        Icons.restaurant,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      data['nama_kuliner'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      data['deskripsi'] ??
                                          'Tidak ada deskripsi',
                                    ),
                                    trailing: Text(
                                      data['daerah'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // ==============================================================
                        const SizedBox(height: 32),
                        _buildTripCompletionSection(context, itinerary),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Sisa Fungsi Pendukung Lainnya ---
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInviteCodeRow(BuildContext context, String code, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoRow(Icons.qr_code_rounded, 'Kode Undangan', code, color),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kode undangan berhasil disalin!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollaboratorsBar(List<Map<String, dynamic>> profiles) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: profiles
          .map(
            (p) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 16),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMockMap(LatLng center, Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: const Center(child: Icon(Icons.map)),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Widget _buildPlacesList(
    List<ItineraryItemModel> places,
    ItineraryModel itinerary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    if (places.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey.shade200,
          ),
        ),
        child: Text(
          'Belum ada tempat wisata yang di-generate.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final Map<int, List<ItineraryItemModel>> groupedPlaces = {};
    for (var item in places) {
      groupedPlaces.putIfAbsent(item.dayNumber, () => []).add(item);
    }

    final sortedDays = groupedPlaces.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDays.map((day) {
        final dayPlaces = groupedPlaces[day]!;
        return ExpansionTile(
          title: Text(
            'Hari $day',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: dayPlaces
              .map(
                (item) => ListTile(
                  title: Text(item.place.name),
                  subtitle: Text(item.place.category),
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }

  Widget _buildTripCompletionSection(
    BuildContext context,
    ItineraryModel itinerary,
  ) {
    return CheckboxListTile(
      title: const Text('Tandai Seluruh Perjalanan Selesai'),
      value: itinerary.isCompleted,
      onChanged: (bool? value) => _toggleTripCompletion(itinerary),
    );
  }
}
