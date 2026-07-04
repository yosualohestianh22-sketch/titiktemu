import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:titik_temu/models/itinerary_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nama koleksi utama di Firestore
  final String collectionName = 'itineraries';

  String _generateInviteCode() {
    final rand = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  // 1. Fungsi Create: Membuat jadwal baru dengan kode undangan & sharedWith
  Future<void> createItinerary(ItineraryModel itinerary) async {
    try {
      final code = _generateInviteCode();
      final data = itinerary.toMap();
      data['inviteCode'] = code;
      data['sharedWith'] = [itinerary.ownerId];

      await _db.collection(collectionName).add(data);
    } catch (e) {
      throw Exception('Gagal menyimpan jadwal: $e');
    }
  }

  // 2. Fungsi Read: Mengambil daftar jadwal milik user tertentu secara Realtime (Stream)
  // Query menggunakan 'sharedWith' arrayContains agar mendeteksi collaborator & owner
  Stream<List<ItineraryModel>> getUserItineraries(String userId) {
    return _db
        .collection(collectionName)
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ItineraryModel.fromMap(doc.data(), doc.id))
              .toList();
          // Lakukan pengurutan secara lokal untuk menghindari kebutuhan Composite Index di Firestore
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // 3. Fungsi Delete: Menghapus jadwal
  Future<void> deleteItinerary(String itineraryId) async {
    try {
      await _db.collection(collectionName).doc(itineraryId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus jadwal: $e');
    }
  }

  // 4. Fungsi Update: Memperbarui data itinerary
  Future<void> updateItinerary(String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionName).doc(docId).update(data);
    } catch (e) {
      throw Exception('Gagal memperbarui jadwal: $e');
    }
  }

  // 5. Fungsi Stream: Mengambil detail itinerary tertentu secara Realtime
  Stream<ItineraryModel> getItineraryStream(String docId) {
    return _db.collection(collectionName).doc(docId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Jadwal tidak ditemukan');
      }
      return ItineraryModel.fromMap(doc.data()!, doc.id);
    });
  }

  // 6. Fungsi Join: Gabung ke itinerary menggunakan kode undangan alfanumerik
  Future<String> joinItineraryWithCode(String code, String userId) async {
    try {
      final normalizedCode = code.trim().toUpperCase();
      final querySnapshot = await _db
          .collection(collectionName)
          .where('inviteCode', isEqualTo: normalizedCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Kode undangan tidak ditemukan');
      }

      final doc = querySnapshot.docs.first;
      final itineraryData = doc.data();
      final List<dynamic> sharedWith = itineraryData['sharedWith'] ?? [];

      if (sharedWith.contains(userId)) {
        throw Exception('Anda sudah bergabung dalam perjalanan ini');
      }

      sharedWith.add(userId);
      await doc.reference.update({'sharedWith': sharedWith});

      return itineraryData['title'] ?? 'Perjalanan';
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 7. Stream Profiles: Mengambil data profil kolaborator secara realtime
  Stream<List<Map<String, dynamic>>> getCollaboratorsProfiles(
    List<String> uids,
  ) {
    if (uids.isEmpty) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .where('uid', whereIn: uids)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
