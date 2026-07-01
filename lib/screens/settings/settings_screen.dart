import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titik_temu/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Mode Terang';
      case ThemeMode.dark:
        return 'Mode Gelap';
      case ThemeMode.system:
        return 'Ikuti Sistem';
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.wb_sunny_outlined;
      case ThemeMode.dark:
        return Icons.nights_stay_outlined;
      case ThemeMode.system:
        return Icons.settings_brightness_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Section: Tampilan
          Text(
            'TAMPILAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getThemeModeIcon(currentMode),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: const Text(
                      'Tema Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(_getThemeModeString(currentMode)),
                    trailing: DropdownButton<ThemeMode>(
                      value: currentMode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down_rounded, size: 30),
                      borderRadius: BorderRadius.circular(16),
                      onChanged: (ThemeMode? newMode) {
                        if (newMode != null) {
                          themeProvider.setThemeMode(newMode);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Terang'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Gelap'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Sistem'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Section: Tentang Aplikasi
          Text(
            'TENTANG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAboutRow(context, 'Nama Aplikasi', 'TitikTemu'),
                  const Divider(height: 24),
                  _buildAboutRow(context, 'Versi', '1.0.0'),
                  const Divider(height: 24),
                  _buildAboutRow(
                    context,
                    'Tujuan',
                    'Aplikasi Perencana Liburan Kolaboratif',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
