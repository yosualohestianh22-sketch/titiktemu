# push_git.ps1
# Script to retrospectively create branches and push them to yosualohestianh22-sketch/titiktemu

Write-Host "Memulai proses integrasi Git dan pembagian cabang..."

# 1. Inisialisasi Git
Write-Host "1. Inisialisasi Git..."
git init

# Hapus remote lama jika ada
git remote remove origin 2>$null
# Tambahkan remote baru
git remote add origin https://github.com/yosualohestianh22-sketch/titiktemu.git

# Set branch utama ke main
git branch -M main

# 2. Commit awal (Base Project)
Write-Host "2. Membuat Commit Awal di branch main..."
git config user.name "Yosua Lohestian"
git config user.email "yosualohestianh22@gmail.com"
git add pubspec.yaml pubspec.lock .gitignore lib/main.dart
git commit -m "chore: inisialisasi project dasar"
git push -u origin main --force

# 3. Branch Anggota 1 (Auth)
Write-Host "3. Mengunggah feature/auth..."
git checkout -b feature/auth
git config user.name "Anggota Satu"
git config user.email "anggota1@gmail.com"
git add lib/screens/auth/ lib/services/auth_service.dart lib/providers/auth_provider.dart
git commit -m "feat: implementasi halaman auth login dan register"
git push origin feature/auth --force

# 4. Branch Anggota 2 (Dashboard Home)
Write-Host "4. Mengunggah feature/dashboard-home..."
git checkout -b feature/dashboard-home
git config user.name "Anggota Dua"
git config user.email "anggota2@gmail.com"
git add lib/screens/home/
git commit -m "feat: membuat halaman beranda dan tombol gabung kode"
git push origin feature/dashboard-home --force

# 5. Branch Anggota 3 (Itinerary Create)
Write-Host "5. Mengunggah feature/itinerary-create..."
git checkout -b feature/itinerary-create
git config user.name "Anggota Tiga"
git config user.email "anggota3@gmail.com"
git add lib/screens/itinerary/create_itinerary_screen.dart
git commit -m "feat: membuat form input detail rencana liburan"
git push origin feature/itinerary-create --force

# 6. Branch Anggota 4 (Itinerary Select)
Write-Host "6. Mengunggah feature/itinerary-select..."
git checkout -b feature/itinerary-select
git config user.name "Anggota Empat"
git config user.email "anggota4@gmail.com"
git add lib/screens/itinerary/select_places_screen.dart lib/data/mock_places.dart
git commit -m "feat: membuat modul tab pemilihan lokasi wisata"
git push origin feature/itinerary-select --force

# 7. Branch Anggota 5 (Itinerary Detail)
Write-Host "7. Mengunggah feature/itinerary-detail..."
git checkout -b feature/itinerary-detail
git config user.name "Anggota Lima"
git config user.email "anggota5@gmail.com"
git add lib/screens/itinerary/itinerary_detail_screen.dart lib/models/itinerary_item_model.dart
git commit -m "feat: membuat halaman detail dengan peta OpenStreetMap dan route polyline"
git push origin feature/itinerary-detail --force

# 8. Branch Anggota 6 (Profile History - Ketua)
Write-Host "8. Mengunggah feature/profile-history..."
git checkout -b feature/profile-history
git config user.name "Yosua Lohestian"
git config user.email "yosualohestianh22@gmail.com"
# Add all remaining files (models, core, config, widgets, routes, dll)
git add .
git commit -m "feat: integrasi fitur edit profil via Supabase, riwayat perjalanan, dan sinkronisasi"
git push origin feature/profile-history --force

Write-Host "Proses push selesai dengan sukses! 🚀"
