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
      data: {
        'full_name': fullName,
        'role': role.name,
      }, // Optional: storing metadata in auth.users as well
    );

    final User? user = res.user;

    if (user == null) {
      throw Exception('Registration failed: User is null');
    }

    if (res.session == null) {
      // Session might be null if email confirmation is required.
      // We can't insert into profiles as the user if we don't have a session.
      // Depending on app settings, we might want to throw or just warn.
      throw Exception(
        'Registration successful, but no session returned. Please check your email for confirmation link or disable "Confirm Email" in Supabase settings.',
      );
    }

    // 2. Insert into public.profiles
    // Table definition:
    // create table public.profiles (
    //   id uuid not null,
    //   full_name text not null,
    //   role public.user_role not null,
    //   created_at timestamp with time zone null default now(),
    //   constraint profiles_pkey primary key (id),
    //   constraint profiles_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
    // )

    final profileData = {
      'id': user.id,
      'full_name': fullName,
      'role': role.name, // Postgres enum 'user' or 'admin'
      // 'created_at': Let DB handle default now()
    };

    try {
      // Use upsert to check for existence or just overwrite to be safe
      await supabaseClient.from('profiles').upsert(profileData).select();
    } catch (e) {
      // If profile insertion fails, we should inform the user.
      throw Exception('Failed to create profile: $e');
    }

    // Return the UserModel
    return UserModel.fromJson({
      ...profileData,
      'email': email,
      'created_at': DateTime.now().toIso8601String(), // Fallback for model
    }, email);
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
