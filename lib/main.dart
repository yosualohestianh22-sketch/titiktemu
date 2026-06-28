import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_temu/firebase_options.dart';
import 'package:titik_temu/core/theme.dart';
import 'package:titik_temu/screens/splash_screen.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/providers/itinerary_provider.dart';
import 'package:titik_temu/providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Wajib dipanggil sebelum Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengaktifkan Firebase sesuai platform (Android/Web/iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase for Storage
  await Supabase.initialize(
    url: 'https://jfqeluwjlmcjkofrhjws.supabase.co',
    publishableKey: 'sb_publishable_GRb--CkuC6Y0Ag7TPc5Cgg_ivFfqddz',
  );

  // Memuat preferensi tema terakhir dari shared_preferences
  final prefs = await SharedPreferences.getInstance();
  final initialThemeStr = prefs.getString('theme_mode') ?? 'system';

  // Inisialisasi locale id_ID untuk formatting tanggal
  await initializeDateFormatting('id_ID', null);
  
  // Membungkus aplikasi dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialThemeStr)),
      ],
      child: const TitikTemuApp(),
    ),
  );
}

class TitikTemuApp extends StatelessWidget {
  const TitikTemuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'TitikTemu',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" merah
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme, // Tema Light
      darkTheme: AppTheme.darkTheme, // Tema Dark
      home: const SplashScreen(), // Memulai aplikasi dari layar pembuka
    );
  }
}
