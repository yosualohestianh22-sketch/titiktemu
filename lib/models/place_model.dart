class PlaceModel {
  final String id;
  final String name;
  final String city;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final double price;
  final String imageUrl;

  PlaceModel({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
