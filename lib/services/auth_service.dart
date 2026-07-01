import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan data user yang sedang login
  User? get currentUser => _auth.currentUser;

  // Fungsi Register (Daftar Akun Baru)
  Future<UserCredential> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // 1. Mendaftarkan email & password ke Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Menyimpan nama pengguna ke Firestore Database
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update display name di profil Auth
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Menangani pesan error umum agar ramah dibaca pengguna
      if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah. Minimal 6 karakter.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Akun sudah ada untuk email tersebut.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan saat pendaftaran.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fungsi Login (Masuk)
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw Exception('Email atau Password salah.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan saat login.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fungsi Logout (Keluar)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Fungsi Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan saat mereset password.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update Profile
  Future<void> updateProfile(String name, Uint8List? imageBytes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Tidak ada user yang login.');

      String? photoUrl;

      // Upload image to Supabase if provided
      if (imageBytes != null) {
        final fileName =
            '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(
              fileName,
              imageBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );

        // Dapatkan URL publik
        photoUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // Update FirebaseAuth
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore
      Map<String, dynamic> updateData = {'name': name};
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }
      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      throw Exception('Gagal mengupdate profil: $e');
    }
  }

  // Update Password
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Tidak ada user yang login.');

      // Re-authenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Kata sandi saat ini salah.');
      }
      throw Exception(e.message ?? 'Gagal mengubah kata sandi.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
