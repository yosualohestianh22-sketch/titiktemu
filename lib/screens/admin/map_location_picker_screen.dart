import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final String city;
  final LatLng? initialLocation;

  const MapLocationPickerScreen({
    super.key,
    required this.city,
    this.initialLocation,
  });

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late LatLng _currentLocation;
  final MapController _mapController = MapController();

  // Koordinat pusat kota bawaan
  static final Map<String, LatLng> _cityCoordinates = {
    'Yogyakarta': const LatLng(-7.7956, 110.3695),
    'Bali': const LatLng(-8.4095, 115.1889),
    'Jakarta': const LatLng(-6.2088, 106.8456),
    'Bandung': const LatLng(-6.9175, 107.6191),
    'Lombok': const LatLng(-8.6529, 116.3249),
    'Surabaya': const LatLng(-7.2575, 112.7521),
    'Labuan Bajo': const LatLng(-8.4907, 119.8827),
    'Borneo': const LatLng(-0.9619, 114.0768),
    'Makassar': const LatLng(-5.1476, 119.4327),
    'Raja Ampat': const LatLng(-0.5000, 130.5000),
  };

  @override
  void initState() {
    super.initState();
    // Gunakan lokasi awal yang dikirimkan, atau cari koordinat default kota, atau fallback ke Yogyakarta
    _currentLocation =
        widget.initialLocation ??
        _cityCoordinates[widget.city] ??
        const LatLng(-7.7956, 110.3695);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Lokasi di Peta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              'Kota tujuan: ${widget.city}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // OpenStreetMap Widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _currentLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.titik_temu',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Petunjuk di bagian atas
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: const Color(0xFF1E293B).withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ketuk di peta untuk memindahkan pin lokasi secara akurat.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Detail Koordinat & Tombol Konfirmasi di bagian bawah
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card detail koordinat
                Card(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'LATITUDE',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white60,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentLocation.latitude.toStringAsFixed(6),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.white24),
                        Column(
                          children: [
                            const Text(
                              'LONGITUDE',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white60,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentLocation.longitude.toStringAsFixed(6),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Konfirmasi
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context, _currentLocation);
                    },
                    child: const Text(
                      'Gunakan Lokasi Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
