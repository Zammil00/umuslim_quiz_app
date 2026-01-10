import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<UserModel> signIn({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    // 1. Sign up the user in Supabase Auth
    final AuthResponse res = await supabaseClient.auth.signUp(
      email: email,
      password: password,
    );

    final User? user = res.user;

    if (user == null) {
      throw Exception('Registration failed: User is null');
    }

    // 2. Insert into public.profiles
    final profileData = {
      'id': user.id,
      'full_name': fullName,
      'role': role.name, // 'admin' or 'user'
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabaseClient.from('profiles').insert(profileData);
    } catch (e) {
      // If profile insertion fails, we might want to clean up the auth user or throw specific error
      throw Exception('Failed to create profile: $e');
    }

    // Return the UserModel
    // Since we just inserted it, we can construct it back or fetch it.
    // For efficiency, we construct it.
    return UserModel.fromJson(profileData, email);
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Sign in with Supabase
    final AuthResponse res = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final User? user = res.user;
    if (user == null) {
      throw Exception('Login failed: User is null');
    }

    // 2. Fetch profile data
    try {
      final data = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Profile not found, this could be a data inconsistency
        throw Exception('User profile not found. Please contact support.');
      }

      return UserModel.fromJson(data, email);
    } catch (e) {
      if (e.toString().contains('User profile not found')) {
        rethrow;
      }
      throw Exception('Failed to fetch profile: $e');
    }
  }
}
