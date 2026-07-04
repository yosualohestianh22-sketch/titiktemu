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

  // Let's define default coordinates for some popular cities
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
    // Default to Indonesia center coordinates if not matched
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
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
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
      // Tandai semua hari selesai
      final totalDays =
          itinerary.endDate.difference(itinerary.startDate).inDays + 1;
      completed = List<int>.generate(totalDays, (i) => i + 1);
    } else {
      // Batalkan semua hari
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
                          : 'Rp ${_formatNumber(placeItem.place.price)}',
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
  Widget build(BuildContext context) {
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

        // Generate List of LatLng for polyline
        final List<LatLng> routePoints = itinerary.places
            .map((item) => LatLng(item.place.latitude, item.place.longitude))
            .toList();

        // Create markers for each place
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

        // Add Hotel to markers if present
        if (itinerary.hotelLatitude != null && itinerary.hotelLongitude != null) {
          final hotelLatLng = LatLng(itinerary.hotelLatitude!, itinerary.hotelLongitude!);
          placeMarkers.add(
            Marker(
              point: hotelLatLng,
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🏨 Hotel: ${itinerary.hotelName} (Rp ${_formatNumber(itinerary.hotelPrice ?? 0)} / malam)'),
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
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.hotel_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          );
          
          // Add to bounds points
          routePoints.add(hotelLatLng);
        }

        // Determine Bounds to fit all points
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
              // Elegant Header Image/Map Sliver
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
                      // Google Map or Mock Map
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
                      // Floating button to open Google Maps Route
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
                      // Elegant bottom gradient for text contrast
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
                      // Positioned Itinerary Title & City
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
                        // Travel details card
                        Card(
                          elevation: 4,
                          color: Theme.of(context).cardColor,
                          shadowColor: themePrimary.withValues(
                            alpha: isDark ? 0.3 : 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[850]!
                                  : Colors.transparent,
                              width: 1,
                            ),
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

                        // Rute Perjalanan (Daftar Wisata)
                        const Text(
                          'Rute Perjalanan & Lokasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Render daftar wisata
                        _buildPlacesList(itinerary.places, itinerary),

                        const SizedBox(height: 24),
                        // Trip completion section
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

  // --- Widget Tambahan untuk Daftar Wisata ---

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // KM
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
          'Belum ada tempat wisata yang di-generate. Coba buat itinerary baru.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Kelompokkan wisata berdasarkan hari
    final Map<int, List<ItineraryItemModel>> groupedPlaces = {};
    for (var item in places) {
      groupedPlaces.putIfAbsent(item.dayNumber, () => []).add(item);
    }

    final sortedDays = groupedPlaces.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDays.map((day) {
        final dayPlaces = groupedPlaces[day]!;
        final dayDate = itinerary.startDate.add(Duration(days: day - 1));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: themePrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Hari $day',
                      style: TextStyle(
                        color: isDark ? Colors.deepPurple[900] : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(dayDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  // Checklist Hari
                  _buildDayCheckbox(context, day, itinerary),
                ],
              ),
            ),
            ...dayPlaces.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              double? distance;
              if (idx > 0) {
                final prevItem = dayPlaces[idx - 1];
                distance = _calculateDistance(
                  prevItem.place.latitude,
                  prevItem.place.longitude,
                  item.place.latitude,
                  item.place.longitude,
                );
              }
              return _buildPlaceCard(item, distance);
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDayCheckbox(
    BuildContext context,
    int day,
    ItineraryModel itinerary,
  ) {
    final isCompleted = itinerary.completedDays.contains(day);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _toggleDayCompletion(itinerary, day),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.15)
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isCompleted
                  ? Colors.green
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isCompleted ? 'Selesai' : 'Tandai Selesai',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCompleted
                    ? Colors.green
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCompletionSection(
    BuildContext context,
    ItineraryModel itinerary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;
    final isCompleted = itinerary.isCompleted;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: isCompleted
          ? Container(
              key: const ValueKey('completed_banner'),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF11998e),
                    Color(0xFF38ef7d),
                  ], // Gradien hijau premium
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Perjalanan Selesai Semua! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat! Anda telah menyelesaikan seluruh rangkaian jadwal liburan ini dengan sukses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _toggleTripCompletion(itinerary),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Batalkan Status Selesai',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              key: const ValueKey('uncompleted_button'),
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _toggleTripCompletion(itinerary),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text(
                  'Selesaikan Perjalanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themePrimary,
                  foregroundColor: isDark
                      ? Colors.deepPurple[900]
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
    );
  }

  Widget _buildPlaceCard(ItineraryItemModel item, double? distanceToPrev) {
    final place = item.place;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openGoogleMaps(place.latitude, place.longitude),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Gambar Tempat
                Image.network(
                  place.imageUrl,
                  width: 110,
                  height: 125,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 110,
                      height: 125,
                      color: isDark ? Colors.grey[800] : Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                // Detail Teks
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? themePrimary.withValues(alpha: 0.15)
                                    : const Color(0xFFF3E5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                place.category,
                                style: TextStyle(
                                  color: isDark
                                      ? themePrimary
                                      : const Color(0xFF6A1B9A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Duration badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.durationHours} Jam',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 14,
                              color: isDark ? Colors.grey[400] : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.price == 0
                                  ? 'Gratis'
                                  : 'Rp ${NumberFormat('#,###', 'id_ID').format(place.price)}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (distanceToPrev != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Jarak: ${distanceToPrev.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Tombol Navigasi kecil di kanan
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themePrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.navigation_rounded,
                      color: themePrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color primaryColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCodeRow(
    BuildContext context,
    String code,
    Color primaryColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.people_alt_rounded, color: primaryColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kode Undangan Rekan',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    code.isEmpty ? 'Generasi...' : code,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (code.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kode undangan "$code" berhasil disalin!',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockMap(LatLng targetLatLng, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1F2E35) : const Color(0xFFE0F7FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 64, color: primaryColor),
            const SizedBox(height: 12),
            Text(
              'Mock Map: ${widget.itinerary.city}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coordinate: ${targetLatLng.latitude.toStringAsFixed(4)}, ${targetLatLng.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Menggunakan Fallback Peta Indah',
                style: TextStyle(
                  color: isDark ? Colors.deepPurple[900] : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorsBar(List<Map<String, dynamic>> profiles) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profiles.isEmpty) return const SizedBox.shrink();

    // Figma border colors
    final List<Color> borderColors = [
      Colors.blue,
      Colors.orange,
      Colors.pink,
      Colors.green,
      Colors.purple,
    ];

    const double avatarSize = 30.0;
    const double overlap = 8.0;

    final displayProfiles = profiles.take(4).toList();
    final remainingCount = profiles.length - displayProfiles.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: avatarSize,
          width: displayProfiles.isEmpty
              ? 0
              : (displayProfiles.length * (avatarSize - overlap)) + overlap,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(displayProfiles.length, (index) {
              final profile = displayProfiles[index];
              final name = profile['name'] ?? 'Traveler';
              final photoUrl = profile['photoUrl'];
              final color = borderColors[index % borderColors.length];

              return Positioned(
                left: index * (avatarSize - overlap),
                child: Tooltip(
                  message: name,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'T',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (remainingCount > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$remainingCount',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
