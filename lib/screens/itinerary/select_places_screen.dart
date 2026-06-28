import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:titik_temu/data/mock_places.dart';
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

  const SelectPlacesScreen({
    super.key,
    required this.title,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.budget,
  });

  @override
  State<SelectPlacesScreen> createState() => _SelectPlacesScreenState();
}

class _SelectPlacesScreenState extends State<SelectPlacesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _tripDays;
  final Map<int, List<PlaceModel>> _selectedPlacesPerDay = {};
  
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

  Future<void> _saveItinerary() async {
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
    );

    final itineraryProvider = context.read<ItineraryProvider>();
    final success = await itineraryProvider.createItinerary(newItinerary);

    if (success) {
      if (!mounted) return;
      // Pop kembali ke halaman awal (melewati CreateItineraryScreen)
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil dibuat!'), backgroundColor: Colors.green),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itineraryProvider.errorMessage), backgroundColor: Colors.red),
      );
    }
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
                        Text(
                          'Pilih Wisata untuk Hari $dayNumber',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        final isTargetCity = city.toLowerCase().trim() == widget.city.toLowerCase().trim();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          color: isDark ? const Color(0xFF161622) : Colors.grey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: isTargetCity,
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.location_city_rounded,
                                    color: isTargetCity ? themePrimary : Colors.grey,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                        color: isTargetCity ? themePrimary : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: places.map((place) {
                                final isSelected = _selectedPlacesPerDay[dayNumber]!.contains(place);

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                          width: 50, height: 50, color: isDark ? Colors.grey[800] : Colors.grey.shade200,
                                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      place.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          place.category,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const Text(' • '),
                                        Text(
                                          place.price == 0
                                              ? 'Gratis'
                                              : 'Rp ${NumberFormat('#,###', 'id_ID').format(place.price)}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected
                                            ? (isDark ? Colors.grey[800] : Colors.grey.shade300)
                                            : themePrimary,
                                        foregroundColor: isSelected
                                            ? (isDark ? Colors.white70 : Colors.black54)
                                            : (isDark ? Colors.deepPurple[900] : Colors.white),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          if (isSelected) {
                                            _selectedPlacesPerDay[dayNumber]!.remove(place);
                                          } else {
                                            _selectedPlacesPerDay[dayNumber]!.add(place);
                                          }
                                        });
                                        // trigger rebuild in parent as well
                                        setState(() {});
                                      },
                                      child: Text(isSelected ? 'Hapus' : 'Tambah'),
                                    ),
                                  ),
                                );
                              }).toList(),
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
        title: const Text('Susun Jadwal Manual', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          tabs: List.generate(_tripDays, (index) => Tab(text: 'Hari ${index + 1}')),
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
                      const SizedBox(height: 20),
                      if (selectedPlaces.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.map_outlined, size: 64, color: isDark ? Colors.grey[750] : Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada wisata untuk Hari $dayNumber',
                                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...selectedPlaces.asMap().entries.map((entry) {
                          final pIndex = entry.key;
                          final place = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark ? Colors.grey[850]! : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
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
                              title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${place.city} • ${place.category}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedPlacesPerDay[dayNumber]!.removeAt(pIndex);
                                  });
                                },
                              ),
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
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _saveItinerary,
            style: ElevatedButton.styleFrom(
              backgroundColor: themePrimary,
              foregroundColor: isDark ? Colors.deepPurple[900] : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
