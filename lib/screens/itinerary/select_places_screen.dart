import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:titik_temu/data/mock_places.dart';
import 'package:titik_temu/data/mock_hotels.dart';
import 'package:titik_temu/models/itinerary_item_model.dart';
import 'package:titik_temu/models/itinerary_model.dart';
import 'package:titik_temu/models/place_model.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/providers/itinerary_provider.dart';

class SelectPlacesScreen extends StatefulWidget {
  final String title;
  final String city;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int travelersCount;

  const SelectPlacesScreen({
    super.key,
    required this.title,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.travelersCount,
  });

  @override
  State<SelectPlacesScreen> createState() => _SelectPlacesScreenState();
}

class _SelectPlacesScreenState extends State<SelectPlacesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _tripDays;
  final Map<int, List<PlaceModel>> _selectedPlacesPerDay = {};
  final Map<String, int> _placeDurations = {};

  final Map<String, List<PlaceModel>> _groupedPlaces = {};
  final List<String> _sortedCities = [];

  @override
  void initState() {
    super.initState();
    _tripDays = widget.endDate.difference(widget.startDate).inDays + 1;
    _tabController = TabController(length: _tripDays, vsync: this);

    for (int i = 1; i <= _tripDays; i++) {
      _selectedPlacesPerDay[i] = [];
    }

    _loadAvailablePlaces();
  }

  void _loadAvailablePlaces() {
    _groupedPlaces.clear();
    _sortedCities.clear();

    // Group all mock places by their city field
    for (var place in mockPlaces) {
      _groupedPlaces.putIfAbsent(place.city, () => []).add(place);
    }

    // Sort the city names. Put the selected trip city first!
    final targetCityLower = widget.city.toLowerCase().trim();
    String? mainCity;

    for (var city in _groupedPlaces.keys) {
      if (city.toLowerCase().trim() == targetCityLower) {
        mainCity = city;
      } else {
        _sortedCities.add(city);
      }
    }

    _sortedCities.sort();
    if (mainCity != null) {
      _sortedCities.insert(0, mainCity);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // KM
  }

  Future<void> _saveItinerary() async {
    // 1. Hitung total destinasi yang dipilih
    int totalSelected = 0;
    for (int day = 1; day <= _tripDays; day++) {
      totalSelected += (_selectedPlacesPerDay[day] ?? []).length;
    }

    if (totalSelected == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong pilih minimal 1 destinasi wisata!')),
      );
      return;
    }

    // 2. Tampilkan pilihan hotel terdekat
    _showHotelSelectionSheet();
  }

  void _showHotelSelectionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    // Hitung centroid destinasi wisata
    double avgLat = 0;
    double avgLng = 0;
    int totalCount = 0;
    for (int day = 1; day <= _tripDays; day++) {
      for (final p in _selectedPlacesPerDay[day] ?? []) {
        avgLat += p.latitude;
        avgLng += p.longitude;
        totalCount++;
      }
    }
    if (totalCount > 0) {
      avgLat /= totalCount;
      avgLng /= totalCount;
    } else {
      avgLat = -7.7956;
      avgLng = 110.3695; // Jogja fallback
    }

    // Ambil hotel di kota yang sama, urutkan berdasarkan jarak dari centroid
    final cityHotels = mockHotels
        .where((h) => h.city.toLowerCase().trim() == widget.city.toLowerCase().trim())
        .toList();
    
    // Sort berdasarkan jarak
    cityHotels.sort((a, b) {
      final distA = _calculateDistance(avgLat, avgLng, a.latitude, a.longitude);
      final distB = _calculateDistance(avgLat, avgLng, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekomendasi Penginapan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terdekat dari destinasi wisata Anda & sesuai budget',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _submitItineraryToFirestore(null);
                      },
                      child: const Text('Lewati', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: cityHotels.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada hotel rekomendasi di kota ini.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cityHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = cityHotels[index];
                          final distance = _calculateDistance(avgLat, avgLng, hotel.latitude, hotel.longitude);
                          final isWithinBudget = hotel.pricePerNight * _tripDays <= widget.budget;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    hotel.imageUrl,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      height: 140,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.hotel, size: 40),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              hotel.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${hotel.rating}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.grey, size: 14),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hotel.address,
                                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Rp ${NumberFormat('#,###', 'id_ID').format(hotel.pricePerNight)} / malam',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: themePrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Total $_tripDays malam: Rp ${NumberFormat('#,###', 'id_ID').format(hotel.pricePerNight * _tripDays)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isWithinBudget ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              backgroundColor: isWithinBudget ? themePrimary : Colors.grey,
                                              foregroundColor: isWithinBudget ? (isDark ? const Color(0xFF0F172A) : Colors.white) : Colors.white70,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _submitItineraryToFirestore(hotel);
                                            },
                                            child: const Text('Pilih Hotel'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '📍 Jarak: ${distance.toStringAsFixed(1)} km dari pusat destinasi wisata Anda',
                                          style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitItineraryToFirestore(MockHotelModel? selectedHotel) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu.')),
      );
      return;
    }

    List<ItineraryItemModel> finalPlaces = [];
    for (int day = 1; day <= _tripDays; day++) {
      final placesForDay = _selectedPlacesPerDay[day] ?? [];
      for (int i = 0; i < placesForDay.length; i++) {
        finalPlaces.add(
          ItineraryItemModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString() + day.toString(),
            place: placesForDay[i],
            dayNumber: day,
            durationHours: _placeDurations[placesForDay[i].id] ?? 2,
          ),
        );
      }
    }

    final newItinerary = ItineraryModel(
      id: '',
      title: widget.title,
      city: widget.city,
      startDate: widget.startDate,
      endDate: widget.endDate,
      budget: widget.budget,
      ownerId: userId,
      ownerName: authProvider.currentUser?.displayName ?? 'Traveler',
      createdAt: DateTime.now(),
      places: finalPlaces,
      travelersCount: widget.travelersCount,
      hotelName: selectedHotel?.name,
      hotelPrice: selectedHotel?.pricePerNight,
      hotelLatitude: selectedHotel?.latitude,
      hotelLongitude: selectedHotel?.longitude,
      hotelImageUrl: selectedHotel?.imageUrl,
    );

    final itineraryProvider = context.read<ItineraryProvider>();
    final success = await itineraryProvider.createItinerary(newItinerary);

    if (success) {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(itineraryProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int?> _showDurationDialog(PlaceModel place, int dayNumber) async {
    int currentTotal = _selectedPlacesPerDay[dayNumber]!.fold(
      0, (sum, p) => sum + (_placeDurations[p.id] ?? 2)
    );
    int maxAllowed = 24 - currentTotal;
    if (maxAllowed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu kunjungan hari ini sudah habis (maksimal 24 jam)!'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    int selectedDuration = 2; // Default
    if (selectedDuration > maxAllowed) {
      selectedDuration = maxAllowed;
    }

    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Durasi Kunjungan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    place.name,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berapa lama Anda akan beraktivitas di sini?',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Durasi:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      Text(
                        '$selectedDuration Jam',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                  Slider(
                    value: selectedDuration.toDouble(),
                    min: 1,
                    max: maxAllowed.toDouble(),
                    divisions: maxAllowed > 1 ? maxAllowed - 1 : 1,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedDuration = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sisa waktu hari $dayNumber: $maxAllowed jam',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, selectedDuration),
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddPlaceModal(int dayNumber) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Wisata untuk Hari $dayNumber',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sortedCities.length,
                      itemBuilder: (context, cityIndex) {
                        final city = _sortedCities[cityIndex];
                        final places = _groupedPlaces[city] ?? [];
                        final isTargetCity =
                            city.toLowerCase().trim() ==
                            widget.city.toLowerCase().trim();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          color: isDark
                              ? const Color(0xFF161622)
                              : Colors.grey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[850]!
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: isTargetCity,
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.location_city_rounded,
                                    color: isTargetCity
                                        ? themePrimary
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    city,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isTargetCity ? themePrimary : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isTargetCity
                                          ? themePrimary.withValues(alpha: 0.15)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${places.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isTargetCity
                                            ? themePrimary
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: () {
                                final sortedPlaces = List<PlaceModel>.from(places);
                                final hasSelected = _selectedPlacesPerDay[dayNumber]!.isNotEmpty;
                                PlaceModel? lastSelectedPlace;
                                if (hasSelected) {
                                  lastSelectedPlace = _selectedPlacesPerDay[dayNumber]!.last;
                                  sortedPlaces.sort((a, b) {
                                    final distA = _calculateDistance(lastSelectedPlace!.latitude, lastSelectedPlace.longitude, a.latitude, a.longitude);
                                    final distB = _calculateDistance(lastSelectedPlace.latitude, lastSelectedPlace.longitude, b.latitude, b.longitude);
                                    return distA.compareTo(distB);
                                  });
                                }

                                return sortedPlaces.map((place) {
                                  final isSelected = _selectedPlacesPerDay[dayNumber]!.contains(place);
                                  double? distance;
                                  if (hasSelected && !isSelected) {
                                    distance = _calculateDistance(
                                      lastSelectedPlace!.latitude,
                                      lastSelectedPlace.longitude,
                                      place.latitude,
                                      place.longitude,
                                    );
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(8),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          place.imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 50,
                                            height: 50,
                                            color: isDark ? Colors.grey[800] : Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              place.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          if (distance != null && distance <= 5.0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Terdekat',
                                                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(place.category, style: const TextStyle(fontSize: 12)),
                                              const Text(' • '),
                                              Text(
                                                place.price == 0
                                                    ? 'Gratis'
                                                    : 'Rp ${NumberFormat('#,###', 'id_ID').format(place.price)}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          if (distance != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '📍 Jarak: ${distance.toStringAsFixed(1)} km dari ${lastSelectedPlace!.name}',
                                              style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                          if (isSelected) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '⏳ Durasi: ${_placeDurations[place.id] ?? 2} Jam',
                                              style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected
                                              ? (isDark ? Colors.grey[800] : Colors.grey.shade300)
                                              : themePrimary,
                                          foregroundColor: isSelected
                                              ? (isDark ? Colors.white : Colors.grey[800])
                                              : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        onPressed: () async {
                                          if (isSelected) {
                                            setModalState(() {
                                              _selectedPlacesPerDay[dayNumber]!.remove(place);
                                              _placeDurations.remove(place.id);
                                            });
                                            setState(() {});
                                          } else {
                                            final duration = await _showDurationDialog(place, dayNumber);
                                            if (duration != null) {
                                              setModalState(() {
                                                _selectedPlacesPerDay[dayNumber]!.add(place);
                                                _placeDurations[place.id] = duration;
                                              });
                                              setState(() {});
                                            }
                                          }
                                        },
                                        child: Text(isSelected ? 'Hapus' : 'Tambah'),
                                      ),
                                    ),
                                  );
                                }).toList();
                              }(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Susun Jadwal Manual',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themePrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: List.generate(
            _tripDays,
            (index) => Tab(text: 'Hari ${index + 1}'),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tripDays, (index) {
          final dayNumber = index + 1;
          final selectedPlaces = _selectedPlacesPerDay[dayNumber] ?? [];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showAddPlaceModal(dayNumber),
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: const Text('Tambah Wisata'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: themePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: themePrimary, width: 2),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Total Jam Kunjungan Hari Ini
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_filled_rounded, color: Colors.orange[700], size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  'Waktu Kunjungan Hari Ini:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ],
                            ),
                            Text(
                              '${selectedPlaces.fold(0, (sum, p) => sum + (_placeDurations[p.id] ?? 2))} / 24 Jam',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.orange[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      if (selectedPlaces.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 64,
                                  color: isDark
                                      ? Colors.grey[750]
                                      : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada wisata untuk Hari $dayNumber',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...selectedPlaces.asMap().entries.map((entry) {
                          final pIndex = entry.key;
                          final place = entry.value;
                          
                          // Hitung jarak dari tempat sebelumnya pada hari yang sama
                          double? distanceToPrev;
                          if (pIndex > 0) {
                            final prevPlace = selectedPlaces[pIndex - 1];
                            distanceToPrev = _calculateDistance(
                              prevPlace.latitude,
                              prevPlace.longitude,
                              place.latitude,
                              place.longitude,
                            );
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey[850]!
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isDark
                                        ? themePrimary.withValues(alpha: 0.15)
                                        : const Color(0xFFF3E5F5),
                                    child: Text(
                                      '${pIndex + 1}',
                                      style: TextStyle(
                                        color: themePrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${place.city} • ${place.category}'),
                                      const SizedBox(height: 4),
                                      Text(
                                        '⏳ Durasi: ${_placeDurations[place.id] ?? 2} Jam',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedPlacesPerDay[dayNumber]!.removeAt(pIndex);
                                        _placeDurations.remove(place.id);
                                      });
                                    },
                                  ),
                                ),
                                if (distanceToPrev != null)
                                  Container(
                                    margin: const EdgeInsets.only(left: 72, bottom: 12, right: 16),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '📍 Jarak: ${distanceToPrev.toStringAsFixed(1)} km dari ${selectedPlaces[pIndex - 1].name}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _saveItinerary,
            style: ElevatedButton.styleFrom(
              backgroundColor: themePrimary,
              foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Selesai & Simpan Jadwal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
