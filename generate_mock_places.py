import json

regions = {
    "Yogyakarta": [
        {"name": "Candi Prambanan", "category": "Sejarah", "desc": "Candi Hindu terbesar di Indonesia abad ke-9.", "lat": -7.7520, "lng": 110.4915, "price": 50000},
        {"name": "Jalan Malioboro", "category": "Belanja", "desc": "Kawasan perbelanjaan ikonik di pusat kota.", "lat": -7.7926, "lng": 110.3658, "price": 0},
        {"name": "Tebing Breksi", "category": "Alam", "desc": "Bekas tambang kapur disulap jadi taman.", "lat": -7.7816, "lng": 110.0076, "price": 10000},
        {"name": "Pantai Parangtritis", "category": "Alam", "desc": "Pantai ikonik Yogyakarta berpasir hitam.", "lat": -8.0253, "lng": 110.3323, "price": 10000},
        {"name": "Kraton Yogyakarta", "category": "Sejarah", "desc": "Istana resmi Kesultanan Ngayogyakarta.", "lat": -7.8053, "lng": 110.3642, "price": 15000},
        {"name": "Taman Sari", "category": "Sejarah", "desc": "Situs bekas taman atau kebun istana Keraton.", "lat": -7.8100, "lng": 110.3589, "price": 15000},
        {"name": "Candi Ratu Boko", "category": "Sejarah", "desc": "Situs purbakala kompleks istana megah.", "lat": -7.7705, "lng": 110.4894, "price": 40000},
        {"name": "HeHa Sky View", "category": "Hiburan", "desc": "Resto dengan pemandangan kota Yogya dari atas.", "lat": -7.8488, "lng": 110.4789, "price": 20000},
        {"name": "Pantai Indrayanti", "category": "Alam", "desc": "Pantai pasir putih bersih di Gunungkidul.", "lat": -8.1500, "lng": 110.6122, "price": 10000},
        {"name": "Goa Jomblang", "category": "Alam", "desc": "Gua vertikal dengan 'cahaya surga' di dasar gua.", "lat": -8.0287, "lng": 110.6385, "price": 500000},
        {"name": "Hutan Pinus Mangunan", "category": "Alam", "desc": "Hutan pinus sejuk dengan spot foto menarik.", "lat": -7.9272, "lng": 110.4284, "price": 5000},
        {"name": "Museum Ullen Sentalu", "category": "Seni", "desc": "Museum seni & budaya Jawa di Kaliurang.", "lat": -7.5979, "lng": 110.4230, "price": 50000},
        {"name": "Gunung Merapi", "category": "Alam", "desc": "Gunung berapi paling aktif untuk Lava Tour.", "lat": -7.5407, "lng": 110.4457, "price": 300000},
        {"name": "Bukit Bintang", "category": "Hiburan", "desc": "Tempat nongkrong malam lihat gemerlap kota.", "lat": -7.8475, "lng": 110.4786, "price": 0},
        {"name": "Pasar Beringharjo", "category": "Belanja", "desc": "Pasar tradisional legendaris murah meriah.", "lat": -7.7984, "lng": 110.3653, "price": 0},
    ],
    "Bali": [
        {"name": "Garuda Wisnu Kencana", "category": "Budaya", "desc": "Taman budaya dengan patung raksasa GWK.", "lat": -8.8149, "lng": 115.1636, "price": 125000},
        {"name": "Pantai Kuta", "category": "Alam", "desc": "Pantai paling terkenal di Bali, surga peselancar.", "lat": -8.7185, "lng": 115.1686, "price": 0},
        {"name": "Pura Ulun Danu Beratan", "category": "Budaya", "desc": "Pura indah terapung di danau Bedugul.", "lat": -8.2752, "lng": 115.1668, "price": 30000},
        {"name": "Ubud Monkey Forest", "category": "Alam", "desc": "Hutan sakral yang dihuni ratusan kera.", "lat": -8.5190, "lng": 115.2590, "price": 80000},
        {"name": "Pura Tanah Lot", "category": "Budaya", "desc": "Pura ikonik di atas tebing batu karang laut.", "lat": -8.6212, "lng": 115.0868, "price": 20000},
        {"name": "Tegallalang Rice Terrace", "category": "Alam", "desc": "Sawah berundak indah dengan pemandangan hijau.", "lat": -8.4330, "lng": 115.2793, "price": 15000},
        {"name": "Pantai Pandawa", "category": "Alam", "desc": "Pantai eksotis yang tersembunyi di balik tebing kapur.", "lat": -8.8451, "lng": 115.1873, "price": 15000},
        {"name": "Pura Besakih", "category": "Budaya", "desc": "Pura terbesar dan tersuci di Bali.", "lat": -8.3743, "lng": 115.4508, "price": 60000},
        {"name": "Pantai Sanur", "category": "Alam", "desc": "Pantai tenang yang cocok untuk melihat matahari terbit.", "lat": -8.6946, "lng": 115.2635, "price": 0},
        {"name": "Bali Safari and Marine Park", "category": "Hiburan", "desc": "Taman safari besar dengan ratusan spesies hewan.", "lat": -8.6014, "lng": 115.3216, "price": 500000},
        {"name": "Pantai Seminyak", "category": "Alam", "desc": "Pantai dengan klub malam kelas atas dan restoran.", "lat": -8.6913, "lng": 115.1622, "price": 0},
        {"name": "Campuhan Ridge Walk", "category": "Alam", "desc": "Jalur trekking ikonik dengan panorama bukit Ubud.", "lat": -8.5035, "lng": 115.2547, "price": 0},
        {"name": "Waterbom Bali", "category": "Hiburan", "desc": "Taman bermain air kelas dunia di Kuta.", "lat": -8.7291, "lng": 115.1681, "price": 300000},
        {"name": "Danau Batur", "category": "Alam", "desc": "Danau vulkanik yang indah di Kintamani.", "lat": -8.2573, "lng": 115.3946, "price": 25000},
        {"name": "Pura Lempuyang", "category": "Budaya", "desc": "Gerbang Surga dengan latar belakang Gunung Agung.", "lat": -8.3908, "lng": 115.6293, "price": 50000},
    ],
    "Jakarta": [
        {"name": "Monumen Nasional (Monas)", "category": "Sejarah", "desc": "Ikon Jakarta dengan mahkota emas di puncaknya.", "lat": -6.1754, "lng": 106.8272, "price": 15000},
        {"name": "Dunia Fantasi (Dufan)", "category": "Hiburan", "desc": "Taman bermain raksasa di kawasan Ancol.", "lat": -6.1253, "lng": 106.8335, "price": 250000},
        {"name": "Taman Mini Indonesia Indah", "category": "Budaya", "desc": "Taman rangkuman kebudayaan seluruh Indonesia.", "lat": -6.3024, "lng": 106.8952, "price": 25000},
        {"name": "Kota Tua Jakarta", "category": "Sejarah", "desc": "Kawasan bersejarah peninggalan era Batavia.", "lat": -6.1376, "lng": 106.8171, "price": 0},
        {"name": "Seaworld Ancol", "category": "Hiburan", "desc": "Akuarium raksasa dengan koleksi biota laut menakjubkan.", "lat": -6.1265, "lng": 106.8437, "price": 110000},
        {"name": "Kebun Binatang Ragunan", "category": "Alam", "desc": "Kebun binatang tertua di Indonesia yang sangat luas.", "lat": -6.3040, "lng": 106.8202, "price": 4000},
        {"name": "Museum Nasional (Museum Gajah)", "category": "Seni", "desc": "Museum arkeologi, sejarah, etnografi, dan geografi.", "lat": -6.1760, "lng": 106.8216, "price": 10000},
        {"name": "Pantai Indah Kapuk (PIK)", "category": "Hiburan", "desc": "Kawasan hits modern untuk kuliner dan bersepeda.", "lat": -6.1031, "lng": 106.7496, "price": 0},
        {"name": "Museum MACAN", "category": "Seni", "desc": "Museum of Modern and Contemporary Art in Nusantara.", "lat": -6.1915, "lng": 106.7618, "price": 100000},
        {"name": "Gelora Bung Karno (GBK)", "category": "Olahraga", "desc": "Kompleks olahraga raksasa dengan taman yang luas.", "lat": -6.2183, "lng": 106.8018, "price": 0},
        {"name": "Masjid Istiqlal", "category": "Religi", "desc": "Masjid terbesar di Asia Tenggara yang berseberangan dgn Katedral.", "lat": -6.1702, "lng": 106.8314, "price": 0},
        {"name": "Taman Suropati", "category": "Alam", "desc": "Taman rindang di Menteng, asri dan cocok bersantai.", "lat": -6.1996, "lng": 106.8326, "price": 0},
        {"name": "Sarinah", "category": "Belanja", "desc": "Mal tertua Indonesia dengan wajah baru yang kekinian.", "lat": -6.1873, "lng": 106.8239, "price": 0},
        {"name": "Pulau Bidadari", "category": "Alam", "desc": "Pulau terdekat dari daratan Jakarta di Kepulauan Seribu.", "lat": -6.0333, "lng": 106.7483, "price": 200000},
    ],
    "Bandung": [
        {"name": "Kawah Putih", "category": "Alam", "desc": "Danau kawah vulkanik berwarna putih kehijauan.", "lat": -7.1662, "lng": 107.4021, "price": 28000},
        {"name": "Tangkuban Perahu", "category": "Alam", "desc": "Gunung berapi dengan legenda Sangkuriang.", "lat": -6.7596, "lng": 107.6097, "price": 30000},
        {"name": "Jalan Braga", "category": "Sejarah", "desc": "Jalan bersejarah ikonik khas Eropa di Bandung.", "lat": -6.9174, "lng": 107.6096, "price": 0},
        {"name": "Gedung Sate", "category": "Sejarah", "desc": "Bangunan bersejarah landmark kota Bandung.", "lat": -6.9025, "lng": 107.6188, "price": 0},
        {"name": "Lembang Park & Zoo", "category": "Hiburan", "desc": "Kebun binatang modern nan sejuk di Lembang.", "lat": -6.8091, "lng": 107.5960, "price": 70000},
        {"name": "Farmhouse Lembang", "category": "Hiburan", "desc": "Taman bergaya Eropa dengan rumah Hobbit.", "lat": -6.8285, "lng": 107.6033, "price": 30000},
        {"name": "Dusun Bambu", "category": "Alam", "desc": "Resor rekreasi keluarga dengan restoran khas Sunda.", "lat": -6.7915, "lng": 107.5786, "price": 30000},
        {"name": "Trans Studio Bandung", "category": "Hiburan", "desc": "Indoor theme park terbesar.", "lat": -6.9248, "lng": 107.6366, "price": 200000},
        {"name": "Floating Market Lembang", "category": "Kuliner", "desc": "Pasar terapung jajanan khas Jawa Barat.", "lat": -6.8184, "lng": 107.6182, "price": 35000},
        {"name": "Ranca Upas", "category": "Alam", "desc": "Area berkemah dan penangkaran rusa.", "lat": -7.1384, "lng": 107.3916, "price": 25000},
        {"name": "Orchid Forest Cikole", "category": "Alam", "desc": "Taman konservasi anggrek terbesar di Indonesia.", "lat": -6.7801, "lng": 107.6402, "price": 40000},
        {"name": "Saung Angklung Udjo", "category": "Budaya", "desc": "Pusat pelestarian alat musik bambu angklung.", "lat": -6.8973, "lng": 107.6558, "price": 75000},
        {"name": "Bukit Moko", "category": "Alam", "desc": "Tempat terbaik melihat citylights kota Bandung.", "lat": -6.8407, "lng": 107.6559, "price": 15000},
        {"name": "De Ranch", "category": "Hiburan", "desc": "Wisata ala koboi di Lembang.", "lat": -6.8130, "lng": 107.6174, "price": 20000},
    ],
    "Surabaya": [
        {"name": "Monumen Kapal Selam", "category": "Sejarah", "desc": "Monumen kapal selam asli KRI Pasopati 410.", "lat": -7.2660, "lng": 112.7505, "price": 15000},
        {"name": "Tugu Pahlawan", "category": "Sejarah", "desc": "Monumen ikonik perjuangan arek Suroboyo.", "lat": -7.2458, "lng": 112.7378, "price": 0},
        {"name": "House of Sampoerna", "category": "Sejarah", "desc": "Museum pabrik rokok kuno bergaya kolonial.", "lat": -7.2312, "lng": 112.7340, "price": 0},
        {"name": "Kenjeran Park", "category": "Hiburan", "desc": "Taman rekreasi lengkap dengan pagoda & patung Buddha.", "lat": -7.2492, "lng": 112.7981, "price": 15000},
        {"name": "Suroboyo Carnival Park", "category": "Hiburan", "desc": "Taman hiburan malam untuk keluarga.", "lat": -7.3382, "lng": 112.7196, "price": 60000},
        {"name": "Hutan Bambu Keputih", "category": "Alam", "desc": "Taman rindang seperti hutan bambu Sagano di Jepang.", "lat": -7.2941, "lng": 112.8021, "price": 0},
        {"name": "Masjid Nasional Al-Akbar", "category": "Religi", "desc": "Masjid terbesar kedua di Indonesia.", "lat": -7.3366, "lng": 112.7153, "price": 0},
        {"name": "Surabaya North Quay", "category": "Hiburan", "desc": "Area nongkrong mewah di terminal penumpang pelabuhan.", "lat": -7.1979, "lng": 112.7329, "price": 10000},
        {"name": "Kebun Binatang Surabaya", "category": "Alam", "desc": "KBS, kebun binatang tertua dan terbesar di Asia Tenggara.", "lat": -7.2957, "lng": 112.7369, "price": 15000},
        {"name": "Jembatan Suramadu", "category": "Sejarah", "desc": "Jembatan terpanjang penghubung Jawa & Madura.", "lat": -7.1852, "lng": 112.7681, "price": 0},
        {"name": "Kelenteng Sanggar Agung", "category": "Religi", "desc": "Kelenteng ikonik tepi laut dengan patung Kwan Im.", "lat": -7.2483, "lng": 112.8016, "price": 10000},
        {"name": "Museum Pendidikan Surabaya", "category": "Sejarah", "desc": "Museum tematik pendidikan yang dulu sekolah kolonial.", "lat": -7.2560, "lng": 112.7445, "price": 0},
    ],
    "Lombok": [
        {"name": "Gili Trawangan", "category": "Alam", "desc": "Pulau bebas polusi untuk party dan snorkeling.", "lat": -8.3516, "lng": 116.0396, "price": 15000},
        {"name": "Pantai Kuta Mandalika", "category": "Alam", "desc": "Pantai berpasir merica dengan ombak selancar di kawasan sirkuit.", "lat": -8.8920, "lng": 116.2801, "price": 10000},
        {"name": "Gunung Rinjani", "category": "Alam", "desc": "Gunung vulkanik tertinggi kedua dengan Segara Anak.", "lat": -8.4116, "lng": 116.4578, "price": 150000},
        {"name": "Pantai Pink", "category": "Alam", "desc": "Tangsi Beach, pantai dengan pasir berwarna merah muda.", "lat": -8.8687, "lng": 116.5168, "price": 50000},
        {"name": "Bukit Merese", "category": "Alam", "desc": "Bukit hijau luas tempat terbaik melihat sunset Mandalika.", "lat": -8.8950, "lng": 116.3155, "price": 10000},
        {"name": "Gili Meno", "category": "Alam", "desc": "Gili tersepi dengan patung bawah laut yang terkenal.", "lat": -8.3524, "lng": 116.0560, "price": 15000},
        {"name": "Desa Sade", "category": "Budaya", "desc": "Desa adat Suku Sasak yang mempertahankan tradisi kuno.", "lat": -8.8398, "lng": 116.2905, "price": 20000},
        {"name": "Pantai Tanjung Aan", "category": "Alam", "desc": "Pantai tenang dengan bukit-bukit kapur di sekitarnya.", "lat": -8.9056, "lng": 116.3117, "price": 10000},
        {"name": "Gili Air", "category": "Alam", "desc": "Gili yang seimbang antara fasilitas dan ketenangan alam.", "lat": -8.3615, "lng": 116.0827, "price": 15000},
        {"name": "Air Terjun Sendang Gile", "category": "Alam", "desc": "Air terjun sejuk di kaki gunung Rinjani.", "lat": -8.3142, "lng": 116.3932, "price": 10000},
    ]
}

lines = [
    "import '../models/place_model.dart';",
    "",
    "final List<PlaceModel> mockPlaces = ["
]

place_idx = 1
for city, places in regions.items():
    lines.append(f"  // === {city.upper()} ===")
    for p in places:
        lines.append("  PlaceModel(")
        lines.append(f"    id: '{city[:3].lower()}_{place_idx}',")
        lines.append(f"    name: '{p['name']}',")
        lines.append(f"    city: '{city}',")
        lines.append(f"    category: '{p['category']}',")
        lines.append(f"    description: '{p['desc']}',")
        lines.append(f"    latitude: {p['lat']},")
        lines.append(f"    longitude: {p['lng']},")
        lines.append(f"    price: {p['price']},")
        keyword = p['name'].split()[0].lower()
        if keyword in ['jalan', 'candi', 'pantai', 'gunung', 'pulau', 'desa']:
            keyword = p['name'].split()[1].lower() if len(p['name'].split()) > 1 else keyword
        lines.append(f"    imageUrl: 'https://loremflickr.com/400/300/{keyword}',")
        lines.append("  ),")
        place_idx += 1

lines.append("];")

with open(r'C:\Users\ASUS\.gemini\antigravity\scratch\titik_temu\lib\data\mock_places.dart', 'w', encoding='utf-8') as f:
    f.write("\n".join(lines))
