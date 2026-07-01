import 'place_model.dart';

class ItineraryItemModel {
  final String id;
  final PlaceModel place;
  final int dayNumber;
  final int durationHours;

  ItineraryItemModel({
    required this.id,
    required this.place,
    required this.dayNumber,
    this.durationHours = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'place': place.toMap(),
      'dayNumber': dayNumber,
      'durationHours': durationHours,
    };
  }

  factory ItineraryItemModel.fromMap(Map<String, dynamic> map) {
    return ItineraryItemModel(
      id: map['id'] ?? '',
      place: PlaceModel.fromMap(map['place'] ?? {}),
      dayNumber: map['dayNumber']?.toInt() ?? 1,
      durationHours: map['durationHours']?.toInt() ?? 2,
    );
  }
}
