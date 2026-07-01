import 'package:flutter/material.dart';
import 'package:titik_temu/models/itinerary_model.dart';
import 'package:titik_temu/services/firestore_service.dart';

class ItineraryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Membuat Itinerary Baru
  Future<bool> createItinerary(ItineraryModel itinerary) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _firestoreService.createItinerary(itinerary);
      _setLoading(false);
      return true; // Berhasil
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false; // Gagal
    }
  }

  // Menghapus Itinerary
  Future<bool> deleteItinerary(String id) async {
    try {
      await _firestoreService.deleteItinerary(id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Memperbarui Itinerary (seperti status penyelesaian)
  Future<bool> updateItinerary(String docId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateItinerary(docId, data);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Gabung ke itinerary milik rekan kolaborasi menggunakan kode undangan
  Future<String?> joinItineraryWithCode(String code, String userId) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final tripTitle = await _firestoreService.joinItineraryWithCode(
        code,
        userId,
      );
      _setLoading(false);
      return tripTitle;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return null;
    }
  }

  // Fungsi Stream untuk mengambil daftar secara realtime
  Stream<List<ItineraryModel>> getUserItinerariesStream(String userId) {
    return _firestoreService.getUserItineraries(userId);
  }

  // Mengambil stream detail itinerary tertentu secara realtime
  Stream<ItineraryModel> getItineraryStream(String docId) {
    return _firestoreService.getItineraryStream(docId);
  }

  // Mengambil stream profil kolaborator berdasarkan daftar UID secara realtime
  Stream<List<Map<String, dynamic>>> getCollaboratorsProfilesStream(
    List<String> uids,
  ) {
    return _firestoreService.getCollaboratorsProfiles(uids);
  }
}
