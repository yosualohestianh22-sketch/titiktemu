class MockHotelModel {
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final double pricePerNight;
  final double rating;
  final String imageUrl;
  final String address;

  const MockHotelModel({
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.rating,
    required this.imageUrl,
    required this.address,
  });
}

final List<MockHotelModel> mockHotels = [
  // --- YOGYAKARTA ---
  MockHotelModel(
    name: 'Hotel Tentrem Yogyakarta',
    city: 'Yogyakarta',
    latitude: -7.7718,
    longitude: 110.3688,
    pricePerNight: 1800000,
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. P. Mangkubumi No. 72A, Yogyakarta',
  ),
  MockHotelModel(
    name: 'The Phoenix Hotel Yogyakarta',
    city: 'Yogyakarta',
    latitude: -7.7828,
    longitude: 110.3678,
    pricePerNight: 1100000,
    rating: 4.7,
    imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Jendral Sudirman No. 9, Yogyakarta',
  ),
  MockHotelModel(
    name: 'POP! Hotel Sangaji Yogyakarta',
    city: 'Yogyakarta',
    latitude: -7.7811,
    longitude: 110.3672,
    pricePerNight: 300000,
    rating: 4.1,
    imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. AM. Sangaji No. 16-18, Jetis, Yogyakarta',
  ),

  // --- BALI ---
  MockHotelModel(
    name: 'RIMBA by AYANA Bali',
    city: 'Bali',
    latitude: -8.7667,
    longitude: 115.1485,
    pricePerNight: 3200000,
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=500&auto=format&fit=crop&q=60',
    address: 'Sejahtera, Jl. Karang Mas, Jimbaran, Kec. Kuta Sel., Bali',
  ),
  MockHotelModel(
    name: 'Hard Rock Hotel Bali',
    city: 'Bali',
    latitude: -8.7225,
    longitude: 115.1697,
    pricePerNight: 1500000,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500&auto=format&fit=crop&q=60',
    address: 'Jalan Pantai Kuta, Banjar Pande Mas, Kuta, Bali',
  ),
  MockHotelModel(
    name: 'Kuta Central Park Hotel',
    city: 'Bali',
    latitude: -8.7135,
    longitude: 115.1782,
    pricePerNight: 350000,
    rating: 4.2,
    imageUrl: 'https://images.unsplash.com/photo-1568495248636-6432b97bd949?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Patih Jelantik, Kuta, Kabupaten Badung, Bali',
  ),

  // --- JAKARTA ---
  MockHotelModel(
    name: 'Hotel Indonesia Kempinski Jakarta',
    city: 'Jakarta',
    latitude: -6.1952,
    longitude: 106.8234,
    pricePerNight: 2800000,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. M.H. Thamrin No. 1, Menteng, Jakarta Pusat',
  ),
  MockHotelModel(
    name: 'DoubleTree by Hilton Jakarta - Diponegoro',
    city: 'Jakarta',
    latitude: -6.1994,
    longitude: 106.8436,
    pricePerNight: 1200000,
    rating: 4.7,
    imageUrl: 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Pegangsaan Timur No. 17, Cikini, Jakarta Pusat',
  ),
  MockHotelModel(
    name: 'Favehotel Kemang Jakarta',
    city: 'Jakarta',
    latitude: -6.2736,
    longitude: 106.8152,
    pricePerNight: 400000,
    rating: 4.0,
    imageUrl: 'https://images.unsplash.com/photo-1506059612708-99d6c258160e?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Kemang Raya No. 10A, Mampang Prapatan, Jakarta Selatan',
  ),

  // --- BANDUNG ---
  MockHotelModel(
    name: 'The Trans Luxury Hotel Bandung',
    city: 'Bandung',
    latitude: -6.9262,
    longitude: 107.6358,
    pricePerNight: 2200000,
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Gatot Subroto No. 289, Cibangkong, Batununggal, Bandung',
  ),
  MockHotelModel(
    name: 'Hilton Bandung',
    city: 'Bandung',
    latitude: -6.9144,
    longitude: 107.5991,
    pricePerNight: 1300000,
    rating: 4.7,
    imageUrl: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. H.O.S. Cokroaminoto No. 41-43, Pasirkaliki, Bandung',
  ),

  // --- SURABAYA ---
  MockHotelModel(
    name: 'Hotel Majapahit Surabaya MGallery',
    city: 'Surabaya',
    latitude: -7.2588,
    longitude: 112.7388,
    pricePerNight: 1400000,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1554009975-d74653b879f1?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Tunjungan No. 65, Genteng, Surabaya',
  ),
  MockHotelModel(
    name: 'Swiss-Belinn Tunjungan Surabaya',
    city: 'Surabaya',
    latitude: -7.2605,
    longitude: 112.7395,
    pricePerNight: 550000,
    rating: 4.4,
    imageUrl: 'https://images.unsplash.com/photo-1568495248636-6432b97bd949?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Tunjungan No. 101, Genteng, Surabaya',
  ),

  // --- LOMBOK ---
  MockHotelModel(
    name: 'Sheraton Senggigi Beach Resort',
    city: 'Lombok',
    latitude: -8.4988,
    longitude: 116.0456,
    pricePerNight: 1100000,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Raya Senggigi Km. 8, Senggigi, Lombok',
  ),
  MockHotelModel(
    name: 'Novotel Lombok Resort & Villas',
    city: 'Lombok',
    latitude: -8.8988,
    longitude: 116.2912,
    pricePerNight: 950000,
    rating: 4.5,
    imageUrl: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500&auto=format&fit=crop&q=60',
    address: 'Pantai Putri Nyale, Pujut, Kuta, Lombok',
  ),

  // --- LABUAN BAJO ---
  MockHotelModel(
    name: 'AYANA Komodo Waecicu Beach',
    city: 'Labuan Bajo',
    latitude: -8.4688,
    longitude: 119.8712,
    pricePerNight: 3500000,
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=500&auto=format&fit=crop&q=60',
    address: 'Pantai Waecicu, Labuan Bajo, Kabupaten Manggarai Barat, NTT',
  ),
  MockHotelModel(
    name: 'Loccal Collection Hotel Komodo',
    city: 'Labuan Bajo',
    latitude: -8.4892,
    longitude: 119.8805,
    pricePerNight: 1600000,
    rating: 4.7,
    imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Raya Binongko, Labuan Bajo, NTT',
  ),

  // --- BORNEO ---
  MockHotelModel(
    name: 'Maratua Paradise Resort',
    city: 'Borneo',
    latitude: 2.2452,
    longitude: 118.6358,
    pricePerNight: 1750000,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?w=500&auto=format&fit=crop&q=60',
    address: 'Pulau Maratua, Kepulauan Derawan, Kalimantan Timur',
  ),
  MockHotelModel(
    name: 'Swiss-Belhotel Tarakan',
    city: 'Borneo',
    latitude: 3.3252,
    longitude: 117.5888,
    pricePerNight: 850000,
    rating: 4.3,
    imageUrl: 'https://images.unsplash.com/photo-1568495248636-6432b97bd949?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Mulawarman No. 15, Tarakan Barat, Tarakan',
  ),

  // --- MAKASSAR ---
  MockHotelModel(
    name: 'The Rinra Makassar',
    city: 'Makassar',
    latitude: -5.1582,
    longitude: 119.4042,
    pricePerNight: 1200000,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Metro Tanjung Bunga No. 2, Makassar',
  ),
  MockHotelModel(
    name: 'Harper Perintis Makassar',
    city: 'Makassar',
    latitude: -5.1112,
    longitude: 119.5088,
    pricePerNight: 650000,
    rating: 4.4,
    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60',
    address: 'Jl. Perintis Kemerdekaan KM 15, Makassar',
  ),

  // --- RAJA AMPAT ---
  MockHotelModel(
    name: 'Papua Paradise Eco Resort',
    city: 'Raja Ampat',
    latitude: -0.8654,
    longitude: 130.4585,
    pricePerNight: 2800000,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=500&auto=format&fit=crop&q=60',
    address: 'Pulau Birie, Selat Dampier, Raja Ampat, Papua Barat',
  ),
  MockHotelModel(
    name: 'Meridian Adventure Marina Club',
    city: 'Raja Ampat',
    latitude: -0.4288,
    longitude: 130.8012,
    pricePerNight: 1900000,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500&auto=format&fit=crop&q=60',
    address: 'Waisai, Kec. Kota Waisai, Kabupaten Raja Ampat, Papua Barat',
  ),
];
