import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/providers/itinerary_provider.dart';
import 'package:titik_temu/screens/auth/login_screen.dart';
import 'package:titik_temu/screens/profile/edit_profile_screen.dart';
import 'package:titik_temu/screens/profile/change_password_screen.dart';
import 'package:titik_temu/screens/settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool showArrow = true,
  }) {
    final resolvedColor = color ?? Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E1E2C);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: resolvedColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: resolvedColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: resolvedColor),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final itineraryProvider = context.watch<ItineraryProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar & Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(55),
                      child: user?.photoURL != null
                          ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                          : Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 60, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Pengguna',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Statistics Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreamBuilder(
                      stream: itineraryProvider.getUserItinerariesStream(user?.uid ?? ''),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.length : 0;
                        return _buildStatItem(context, count.toString(), 'Perjalanan\nDibuat');
                      },
                    ),
                    Container(height: 40, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                    StreamBuilder(
                      stream: itineraryProvider.getUserItinerariesStream(user?.uid ?? ''),
                      builder: (context, snapshot) {
                        int cities = 0;
                        if (snapshot.hasData) {
                          final uniqueCities = snapshot.data!.map((e) => e.city).toSet();
                          cities = uniqueCities.length;
                        }
                        return _buildStatItem(context, cities.toString(), 'Kota\nDikunjungi');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Menu List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.03), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuOption(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                  ),
                  Divider(height: 1, indent: 70, endIndent: 24, color: isDark ? Colors.grey[850] : Colors.grey[100]),
                  _buildMenuOption(
                    context: context,
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Kata Sandi',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                    },
                  ),
                  Divider(height: 1, indent: 70, endIndent: 24, color: isDark ? Colors.grey[850] : Colors.grey[100]),
                  _buildMenuOption(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                  Divider(height: 1, indent: 70, endIndent: 24, color: isDark ? Colors.grey[850] : Colors.grey[100]),
                  _buildMenuOption(
                    context: context,
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    color: Colors.redAccent,
                    showArrow: false,
                    onTap: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Keluar Akun'),
                          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Keluar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ) ?? false;
                      
                      if (confirm && context.mounted) {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: isDark ? Theme.of(context).primaryColor : const Color(0xFF6A1B9A)
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
