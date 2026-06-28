import 'package:cloud_firestore/cloud_firestore.dart';
import 'itinerary_item_model.dart';

class ItineraryModel {
  final String id;
  final String title;
  final String city;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final List<ItineraryItemModel> places;
  final List<int> completedDays;
  final bool isCompleted;
  final List<String> sharedWith;
  final String inviteCode;

  ItineraryModel({
    required this.id,
    required this.title,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.ownerId,
    this.ownerName = '',
    required this.createdAt,
    this.places = const [],
    this.completedDays = const [],
    this.isCompleted = false,
    this.sharedWith = const [],
    this.inviteCode = '',
  });

  // Konversi dari JSON (Firestore) ke Object Dart
  factory ItineraryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ItineraryModel(
      id: documentId,
      title: data['title'] ?? '',
      city: data['city'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      budget: (data['budget'] ?? 0).toDouble(),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      places: (data['places'] as List<dynamic>?)
              ?.map((item) => ItineraryItemModel.fromMap(item))
              .toList() ??
          [],
      completedDays: List<int>.from(data['completedDays'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      inviteCode: data['inviteCode'] ?? '',
    );
  }

  // Konversi dari Object Dart ke JSON (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'city': city,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'budget': budget,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'places': places.map((e) => e.toMap()).toList(),
      'completedDays': completedDays,
      'isCompleted': isCompleted,
      'sharedWith': sharedWith,
      'inviteCode': inviteCode,
    };
  }
}
