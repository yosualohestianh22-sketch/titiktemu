import 'dart:math';
import '../data/mock_places.dart';
import '../models/itinerary_item_model.dart';
import '../models/place_model.dart';

class ItineraryGeneratorService {
  /// Membangkitkan daftar tempat wisata yang didistribusikan ke dalam hari-hari
  static List<ItineraryItemModel> generateItinerary({
    required String city,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
  }) {
    // 1. Hitung total hari
    final int totalDays = endDate.difference(startDate).inDays + 1;
    if (totalDays <= 0) return [];

    // 2. Ambil data tempat wisata yang sesuai dengan kota
    // Filter dengan pencarian teks fleksibel (ignore case)
    List<PlaceModel> availablePlaces = mockPlaces
        .where((place) => place.city.toLowerCase() == city.toLowerCase())
        .toList();

    // Jika kota belum ada di database mock, kita ambil semua secara random sebagai cadangan
    if (availablePlaces.isEmpty) {
      availablePlaces = List.from(mockPlaces);
    }

    // Acak urutan wisata biar bervariasi setiap kali di-generate
    availablePlaces.shuffle(Random());

    // 3. Logika Distribusi Sederhana (Greedy)
    // - Misal, kita set maksimal 3 tempat per hari
    // - Kita masukkan ke hari selama budget mencukupi
    List<ItineraryItemModel> generatedItems = [];
    double currentSpent = 0;
    int placeIndex = 0;

    for (int day = 1; day <= totalDays; day++) {
      int placesThisDay = 0;

      while (placesThisDay < 3 && placeIndex < availablePlaces.length) {
        final place = availablePlaces[placeIndex];

        // Jika budget masih cukup atau harga tempat = 0 (gratis)
        if (currentSpent + place.price <= budget) {
          generatedItems.add(
            ItineraryItemModel(
              id: 'item_${DateTime.now().millisecondsSinceEpoch}_$placeIndex',
              place: place,
              dayNumber: day,
            ),
          );
          currentSpent += place.price;
          placesThisDay++;
        }

        placeIndex++;
      }

      // Jika kita kehabisan tempat wisata di database untuk kota ini,
      // kita putar balik indeksnya agar hari berikutnya tetap ada isinya (hanya untuk keperluan dummy).
      if (placeIndex >= availablePlaces.length) {
        placeIndex = 0;
        availablePlaces.shuffle(Random());
      }
    }

    return generatedItems;
  }
}
