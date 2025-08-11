import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../utils/constants/route_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // =====================================================
  // AUTHENTICATION METHODS
  // =====================================================

  // Normalize email to avoid hidden/invisible chars and casing issues
  String _normalizeEmail(String email) {
    // Remove zero-width and BOM chars, collapse/strip whitespace, and lowercase
    final noInvisible = email.replaceAll(RegExp(r"[\u200B-\u200D\uFEFF]"), "");
    final noSpaces = noInvisible.replaceAll(RegExp(r"\s+"), "");
    return noSpaces.trim().toLowerCase();
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      print('🔐 [DEBUG] AuthService: Signing up user with email: $normalizedEmail');
      
      final response = await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
      );
      
      print('✅ [DEBUG] AuthService: Signup successful for: $normalizedEmail');
      return response;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Signup failed for $email: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign up with email, password and user metadata for complete profile creation
  Future<AuthResponse> signUpWithEmailAndMetadata({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      print('🔐 [DEBUG] AuthService: Signing up user with email and metadata: $normalizedEmail');
      print('📋 [DEBUG] AuthService: User metadata: $metadata');
      
      final response = await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: metadata, // Pass metadata so database trigger can create complete profile
      );
      
      print('✅ [DEBUG] AuthService: User signed up successfully with metadata');
      return response;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Sign up with metadata failed: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      print('🔐 [DEBUG] AuthService: Signing in user with email: $normalizedEmail');
      
      final response = await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      
      print('✅ [DEBUG] AuthService: Signin successful for: $normalizedEmail');
      return response;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Signin failed for $email: $e');
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign in with phone (OTP)
  Future<void> signInWithPhone({
    required String phone,
  }) async {
    try {
      print('📱 [DEBUG] AuthService: Sending OTP to phone: $phone');
      
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );
      
      print('✅ [DEBUG] AuthService: OTP sent successfully to: $phone');
    } catch (e) {
      print('❌ [DEBUG] AuthService: OTP send failed for $phone: $e');
      throw Exception('Phone sign in failed: $e');
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      print('🔐 [DEBUG] AuthService: Verifying OTP for phone: $phone');
      
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      
      print('✅ [DEBUG] AuthService: OTP verification successful for: $phone');
      return response;
    } catch (e) {
      print('❌ [DEBUG] AuthService: OTP verification failed for $phone: $e');
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      print('🚪 [DEBUG] AuthService: Signing out user');
      
      await _supabase.auth.signOut();
      
      print('✅ [DEBUG] AuthService: Signout successful');
    } catch (e) {
      print('❌ [DEBUG] AuthService: Signout failed: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      print('🔐 [DEBUG] AuthService: Updating password');
      
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      print('✅ [DEBUG] AuthService: Password updated successfully');
    } catch (e) {
      print('❌ [DEBUG] AuthService: Password update failed: $e');
      throw Exception('Password update failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('📧 [DEBUG] AuthService: Sending password reset email to: $email');
      // Build deep link that opens the app to reset password screen
      final redirect = '${RoutePaths.deepLinkPrefix}${RoutePaths.resetPassword}';
      await _supabase.auth.resetPasswordForEmail(email, redirectTo: redirect);
      
      print('✅ [DEBUG] AuthService: Password reset email sent to: $email');
    } catch (e) {
      print('❌ [DEBUG] AuthService: Password reset email failed for $email: $e');
      throw Exception('Password reset email failed: $e');
    }
  }

  // =====================================================
  // USER STATUS METHODS
  // =====================================================

  /// Get current authenticated user
  User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    print('👤 [DEBUG] AuthService: Current user: ${user?.email ?? 'None'}');
    return user;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final authenticated = _supabase.auth.currentUser != null;
    print('🔐 [DEBUG] AuthService: User authenticated: $authenticated');
    return authenticated;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    final userId = _supabase.auth.currentUser?.id;
    print('🆔 [DEBUG] AuthService: Current user ID: $userId');
    return userId;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    final email = _supabase.auth.currentUser?.email;
    print('📧 [DEBUG] AuthService: Current user email: $email');
    return email;
  }

  // =====================================================
  // USER VALIDATION METHODS
  // =====================================================

  /// Check if a user exists by email in the database
  Future<bool> checkUserExistsByEmail(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      print('🔍 [DEBUG] AuthService: Checking if user exists: $normalizedEmail');

      // 1) Try an optional RPC that can securely query auth.users
      try {
        final rpcResult = await _supabase.rpc('user_exists_by_email', params: {
          'p_email': normalizedEmail,
        });
        if (rpcResult is bool) {
          print('🔍 [DEBUG] AuthService: RPC user_exists_by_email -> $rpcResult');
          return rpcResult;
        }
      } on PostgrestException catch (e) {
        // RPC not found or not permitted; fall back to public.users
        print('⚠️ [DEBUG] AuthService: RPC user_exists_by_email not available: ${e.message}');
      } catch (_) {
        // Ignore and fallback
      }

      // 2) Fallback: check public.users for a profile row
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('email', normalizedEmail)
          .maybeSingle();

      final exists = response != null;
      print('🔍 [DEBUG] AuthService: public.users check -> exists=$exists');
      return exists;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Error checking user existence: $e');
      return false;
    }
  }

  /// Check if a user exists by phone in the database
  Future<bool> checkUserExistsByPhone(String phone) async {
    try {
      print('🔍 [DEBUG] AuthService: Checking if user exists by phone: $phone');
      
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      
      final exists = response != null;
      print('🔍 [DEBUG] AuthService: User exists by phone: $exists');
      
      return exists;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Error checking user existence by phone: $e');
      return false;
    }
  }

  // =====================================================
  // USER PROFILE METHODS
  // =====================================================

  /// Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ [DEBUG] AuthService: No authenticated user for profile fetch');
        return null;
      }

      print('👤 [DEBUG] AuthService: Fetching profile for user: ${user.email}');
      
      // Use maybeSingle() instead of single() to handle missing profiles gracefully
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        print('⚠️ [DEBUG] AuthService: No profile found in public.users, creating default profile');
        
        // Create a basic profile for this authenticated user
        try {
          final newProfile = await _supabase
              .from(SupabaseConfig.usersTable)
              .insert({
                'id': user.id,
                'name': user.userMetadata?['name'] ?? 'Player',
                'email': user.email,
                'avatar_url': 'assets/Avatar/default-avatar.svg',
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
          
          print('✅ [DEBUG] AuthService: Created new profile successfully');
          return newProfile;
        } catch (createError) {
          print('❌ [DEBUG] AuthService: Failed to create profile: $createError');
          // Return a minimal profile object
          return {
            'id': user.id,
            'name': 'Player',
            'email': user.email,
            'avatar_url': 'assets/Avatar/default-avatar.svg',
          };
        }
      }
      
      print('✅ [DEBUG] AuthService: Profile fetched successfully');
      return response;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    int? age,
    String? gender,
    List<String>? sports,
    String? intent,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('👤 [DEBUG] AuthService: Updating profile for user: ${user.email}');
      print('📝 [DEBUG] AuthService: Name to update: "$name"');
      print('📝 [DEBUG] AuthService: Age: $age, Gender: $gender');
      
      // Prefer server-side RPC if available for consistent authorization/validation
      try {
        final response = await _supabase.rpc('update_user_profile', params: {
          'user_name': name,
          'user_age': age,
          'user_gender': gender,
          'user_sports': sports,
          'user_intent': intent,
        });

        print('✅ [DEBUG] AuthService: Profile updated successfully via RPC');
        return response;
      } on PostgrestException catch (e) {
        // If RPC is missing (PGRST202) or not yet deployed, fallback to direct table update
        final isMissingRpc = e.code == 'PGRST202' ||
            (e.message.toLowerCase().contains('could not find the function') &&
                e.message.toLowerCase().contains('update_user_profile'));

        if (!isMissingRpc) {
          rethrow;
        }

        print('⚠️ [DEBUG] AuthService: RPC update_user_profile not found. Falling back to direct update.');

        // Build updates map with only non-null values to avoid wiping existing data
        final Map<String, dynamic> updates = {};
        if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
        if (age != null) updates['age'] = age;
        if (gender != null && gender.trim().isNotEmpty) updates['gender'] = gender.trim();
        if (sports != null) updates['sports'] = sports;
        if (intent != null && intent.trim().isNotEmpty) updates['intent'] = intent.trim();

        if (updates.isEmpty) {
          print('ℹ️ [DEBUG] AuthService: No profile fields to update. Returning current profile.');
          final current = await _supabase
              .from(SupabaseConfig.usersTable)
              .select()
              .eq('id', user.id)
              .single();
          return current;
        }

        try {
          final updated = await _supabase
              .from(SupabaseConfig.usersTable)
              .update(updates)
              .eq('id', user.id)
              .select()
              .single();

          print('✅ [DEBUG] AuthService: Profile updated successfully via direct table update');
          return updated;
        } on PostgrestException catch (e2) {
          // Handle schema differences gracefully (e.g., full_name vs name, preferred_sports vs sports)
          final isMissingColumn = e2.code == '42703' || e2.message.toLowerCase().contains('column') && e2.message.toLowerCase().contains('does not exist');
          if (!isMissingColumn) rethrow;

          print('⚠️ [DEBUG] AuthService: Column mismatch on users table. Retrying with alternate column names.');

          final Map<String, dynamic> altUpdates = {};
          // Map name -> full_name if present
          if (updates.containsKey('name')) altUpdates['full_name'] = updates['name'];
          // Map sports -> preferred_sports if present
          if (updates.containsKey('sports')) altUpdates['preferred_sports'] = updates['sports'];
          // Pass-through others
          if (updates.containsKey('age')) altUpdates['age'] = updates['age'];
          if (updates.containsKey('gender')) altUpdates['gender'] = updates['gender'];
          if (updates.containsKey('intent')) altUpdates['intent'] = updates['intent'];

          // If error reveals a specific missing column, drop it from the retry payload
          try {
            final lower = e2.message.toLowerCase();
            final startIdx = lower.indexOf('column ');
            final endIdx = lower.indexOf(' does not exist');
            if (startIdx != -1 && endIdx != -1 && endIdx > startIdx + 7) {
              final rawCol = e2.message.substring(startIdx + 7, endIdx).trim();
              final missingCol = rawCol.replaceAll('u.', '').replaceAll('public.', '').replaceAll('users.', '').trim();
              altUpdates.remove(missingCol);
              // Also remove counterparts if applicable
              if (missingCol == 'name') altUpdates.remove('name');
              if (missingCol == 'sports') altUpdates.remove('sports');
            }
          } catch (_) {/* ignore parsing issues */}

          if (altUpdates.isEmpty) rethrow;

          final updatedAlt = await _supabase
              .from(SupabaseConfig.usersTable)
              .update(altUpdates)
              .eq('id', user.id)
              .select()
              .single();

          print('✅ [DEBUG] AuthService: Profile updated successfully via alternate column names');
          return updatedAlt;
        }
      }
    } catch (e) {
      print('❌ [DEBUG] AuthService: Profile update failed: $e');
      throw Exception('Profile update failed: $e');
    }
  }

  // =====================================================
  // SESSION MANAGEMENT
  // =====================================================

  /// Get current session
  Session? getCurrentSession() {
    final session = _supabase.auth.currentSession;
    print('🔐 [DEBUG] AuthService: Current session: ${session != null ? 'Active' : 'None'}');
    return session;
  }

  /// Check if session is expired
  bool isSessionExpired() {
    final session = _supabase.auth.currentSession;
    if (session == null) return true;
    
    final now = DateTime.now();
    final expiresAt = DateTime.fromMillisecondsSinceEpoch((session.expiresAt ?? 0) * 1000);
    final expired = now.isAfter(expiresAt);
    
    print('⏰ [DEBUG] AuthService: Session expired: $expired');
    return expired;
  }

  /// Refresh session
  Future<AuthResponse?> refreshSession() async {
    try {
      print('🔄 [DEBUG] AuthService: Refreshing session');
      
      final response = await _supabase.auth.refreshSession();
      
      print('✅ [DEBUG] AuthService: Session refreshed successfully');
      return response;
    } catch (e) {
      print('❌ [DEBUG] AuthService: Session refresh failed: $e');
      return null;
    }
  }
}
