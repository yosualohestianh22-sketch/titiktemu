# TitikTemu 🗺️ - Collaborative Travel Itinerary Planner

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-orange.svg?logo=dart)](https://dart.dev)
[![Firebase Integration](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-yellow.svg?logo=firebase)](https://firebase.google.com)
[![Supabase Storage](https://img.shields.io/badge/Supabase-Storage-green.svg?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

**TitikTemu** adalah aplikasi perencana perjalanan kolaboratif (*Collaborative Travel Planner*) berbasis mobile (Android) yang dirancang untuk mempermudah kelompok wisatawan menyusun jadwal liburan (*itinerary*), memilih akomodasi hotel, dan memetakan rute perjalanan secara terintegrasi dan *real-time*.

Aplikasi ini dibangun menggunakan framework **Flutter** dan diintegrasikan dengan arsitektur cloud terdistribusi (**Firebase** dan **Supabase**) untuk menjamin performa yang responsif, modern, dan andal.

---

## 🚀 Fitur Utama Aplikasi

### 👤 Sisi Pengguna (User Features)
*   **Kolaborasi Jadwal Real-Time**: Menyusun rangkaian tempat wisata yang akan dikunjungi bersama teman sekelompok dalam satu rencana perjalanan yang sinkron.
*   **Visualisasi Peta & Jarak**: Menampilkan jalur rute perjalanan visual berbentuk garis putus-putus (*dashed polyline*) di atas peta OpenStreetMap, lengkap dengan perhitungan jarak otomatis antar tempat wisata.
*   **Kustom Kalender Traveloka**: Memilih tanggal liburan menggunakan pemilih tanggal (*date range picker*) premium dengan estetika khas Traveloka, di mana penanggalan hari Minggu secara akurat ditandai dengan warna merah tebal.
*   **Akomodasi Kamar & Tamu**: Bottom sheet interaktif untuk menghitung jumlah kamar, tamu dewasa, dan anak-anak menggunakan kontroler tambah/kurang (+/-).
*   **Rekomendasi Hotel Premium**: Tampilan kartu hotel horizontal berdesain modern (foto di kiri, bintang rating, info jarak, harga sewa per malam, dan total biaya akomodasi di kanan).
*   **Google Maps Launcher**: Navigasi sekali klik untuk membuka rute perjalanan langsung pada aplikasi Google Maps resmi bawaan HP.

### 💼 Sisi Operator (Admin / Operator Panel)
*   **Dasbor Operator Slate Premium**: Halaman dasbor khusus operator bertema gelap (*dark mode*) yang mewah untuk mengontrol data global.
*   **CRUD Data Wisata & Hotel**: Menambah, mengedit, dan menghapus data destinasi wisata (200 pilihan) dan hotel (60 pilihan) di 10 kota besar seluruh Indonesia secara instan.
*   **Map Location Picker**: Input koordinat Latitude dan Longitude secara visual. Cukup klik ikon peta, ketuk lokasi tujuan pada peta OpenStreetMap, dan koordinat desimal akan terisi otomatis.
*   **Cloud Image Upload**: Unggah file foto tempat wisata/hotel langsung dari galeri laptop atau browser ke **Supabase Storage** publik untuk mendapatkan tautan URL gambar instan.
*   **Kelola User & Blokir Akun**: Memantau seluruh daftar pengguna terdaftar dari database Cloud Firestore secara langsung dan menonaktifkan (*suspend*) akses login user nakal.

---

## 🛠️ Arsitektur Teknologi (Tech Stack)

*   **Frontend**: Flutter (Dart) dengan State Management `Provider`.
*   **Typography**: Font **Poppins** diintegrasikan secara global pada tema aplikasi.
*   **Database & Auth**: Firebase Authentication (pengamanan login) dan Cloud Firestore (database NoSQL dokumen real-time).
*   **Cloud Object Storage**: Supabase Storage bucket `avatars` (tempat penyimpanan file gambar unggahan admin).
*   **Mapping Engine**: `flutter_map` berbasis OpenStreetMap (OSM) dan `latlong2`.

---

## 👥 Tim Pengembang & Pembagian Tugas (Contributors)

Proyek ini dikembangkan secara kolaboratif oleh Kelompok 6 dengan pembagian tugas yang tercatat resmi pada riwayat repositori Git:

| Kontributor | Peran Utama | Tanggung Jawab Fitur | Berkas Kodingan Utama |
| :--- | :--- | :--- | :--- |
| **Yosua**<br>(@yosualohestianh22-sketch) | **UI Coordinator & System Integrator** | Mengelola manajemen konflik Git kelompok, integrasi Google Fonts global (Poppins), state management `ThemeProvider` (Light/Dark Mode), dan routing utama aplikasi. | `main.dart`<br>`core/theme.dart`<br>`providers/theme_provider.dart` |
| **Novan**<br>(@Novandanu43) | **Backend & Security Engineer** | Mengintegrasikan registrasi & login Firebase Auth, penyimpanan database user di Firestore, dan penolakan login otomatis bagi akun yang berstatus `'Diblokir'`. | `services/auth_service.dart`<br>`providers/auth_provider.dart`<br>`screens/auth/login_screen.dart` |
| **Panggih**<br>(@Panggih Imam Budhiono) | **Admin Dashboard Developer** | Merancang antarmuka panel kontrol admin (`AdminDashboardScreen`), pemantauan user real-time menggunakan `StreamBuilder`, dan aksi blokir user di Firestore. | `screens/admin/admin_dashboard_screen.dart` |
| **Tasya**<br>(@tasyanurdiana) | **Map Picker & Cloud Storage Specialist** | Membuat peta penangkap koordinat desimal (`MapLocationPickerScreen`) dan unggah file gambar perangkat ke bucket Supabase Storage. | `screens/admin/map_location_picker_screen.dart` |
| **Zahra**<br>(@zarameyy) | **Core UI Planner & Date Picker Designer** | Mengembangkan visualisasi form pembuat itinerary perjalanan, dialog kalender Traveloka, dan Bottom Sheet akomodasi tamu. | `screens/itinerary/create_itinerary_screen.dart`<br>`screens/itinerary/traveloka_date_picker.dart` |
| **Rahmat**<br>(@RahmatHidayatSianturi) | **Recommendation & Mapping Specialist** | Merancang kartu hotel horizontal Traveloka, penggambaran polyline rute jalan, kalkulator jarak otomatis, dan launcher rute Google Maps eksternal. | `screens/itinerary/itinerary_detail_screen.dart`<br>`screens/itinerary/select_places_screen.dart` |

---

## ⚙️ Petunjuk Instalasi & Menjalankan Aplikasi

Ikuti langkah berikut untuk menjalankan proyek ini di perangkat lokal Anda:

### 1. Prasyarat (Prerequisites)
Pastikan laptop Anda sudah terinstal:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.22.0 atau lebih baru)
*   [Java Development Kit (JDK)](https://www.oracle.com/java/technologies/downloads/) (versi 17)
*   Android Studio / VS Code dengan ekstensi Flutter & Dart

### 2. Kloning Repositori (Clone Repository)
```bash
git clone https://github.com/yosualohestianh22-sketch/titiktemu.git
cd titiktemu
```

### 3. Instalasi Package Dependensi
```bash
flutter pub get
```

### 4. Menjalankan Aplikasi (Run Application)
Hubungkan emulator Android atau HP Android asli menggunakan mode Debugging USB, lalu jalankan:
```bash
flutter run
```

### 5. Kompilasi APK Produksi (Build Release APK)
Untuk membuat file APK rilis final yang bisa dibagikan dan diinstal di Android:
```bash
flutter build apk --release
```
File hasil compile akan tersimpan di:  
`build/app/outputs/flutter-apk/app-release.apk`
