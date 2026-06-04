import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign Up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        'bio': '', // Initialize empty bio
      },
    );
    return response;
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Get Current User
  User? get currentUser => _supabase.auth.currentUser;

  // Get Current User Role
  String? get currentRole {
    final user = _supabase.auth.currentUser;
    return user?.userMetadata?['role'] as String?;
  }

  // Upload Avatar to Supabase Storage (Universal Support)
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final fileExt = p.extension(imageFile.name);
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'avatars/$fileName';

      final bytes = await imageFile.readAsBytes();

      await _supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final metadata = {
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    // Update Auth Metadata
    await _supabase.auth.updateUser(
      UserAttributes(data: metadata),
    );

    // Update profiles table with upsert to ensure row exists
    final dbUpdates = {
      'id': user.id,
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': user.userMetadata?['role'] ?? 'Student',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('profiles').upsert(dbUpdates);
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
