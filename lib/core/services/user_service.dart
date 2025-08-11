import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _userKey = 'user_profile';
  static const String _greetingCacheKey = 'greeting_cache';
  static const String _lastGreetingUpdateKey = 'last_greeting_update';

  UserModel? _currentUser;
  String? _cachedGreeting;
  DateTime? _lastGreetingUpdate;
  final AuthService _authService = AuthService();

  // Getters
  UserModel? get currentUser => _currentUser;
  String? get cachedGreeting => _cachedGreeting;
  DateTime? get lastGreetingUpdate => _lastGreetingUpdate;

  // Check if greeting cache is valid (less than 1 hour old)
  bool get isGreetingCacheValid {
    if (_lastGreetingUpdate == null) return false;
    final now = DateTime.now();
    return now.difference(_lastGreetingUpdate!).inHours < 1;
  }

  // Initialize user service
  Future<void> init() async {
    await _loadUserFromSupabase();
    await _loadGreetingCache();
    notifyListeners();
  }

  // Load user from Supabase
  Future<void> _loadUserFromSupabase() async {
    try {
      final userProfile = await _authService.getUserProfile();
      if (userProfile != null) {
        _currentUser = UserModel.fromSupabaseJson(userProfile);
        await _saveUserToStorage(); // Cache locally
      } else {
        // Fallback to local storage if no Supabase profile
        await _loadUserFromStorage();
      }
    } catch (e) {
      // Fallback to local storage on error
      await _loadUserFromStorage();
    }
  }

  // Load user from shared preferences (fallback)
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userMap);
      } else {
        // No cached user; keep unset to avoid stale names during new registrations
        _currentUser = null;
      }
    } catch (e) {
      // On error, leave user unset
      _currentUser = null;
    }
  }

  // Save user to shared preferences
  Future<void> _saveUserToStorage() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
    }
  }

  // Load greeting cache from storage
  Future<void> _loadGreetingCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedGreeting = prefs.getString(_greetingCacheKey);
      
      final lastUpdateString = prefs.getString(_lastGreetingUpdateKey);
      if (lastUpdateString != null) {
        _lastGreetingUpdate = DateTime.parse(lastUpdateString);
      }
    } catch (e) {
      _cachedGreeting = null;
      _lastGreetingUpdate = null;
    }
  }



  // Create default user
  UserModel _createDefaultUser() {
    return UserModel(
      id: 'default_user',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@email.com',
      phone: '+1 234 567 8900',
      bio: 'Sports enthusiast who loves playing football and basketball. Always looking for new games to join!',
      language: 'en',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Update user profile
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      // Update in Supabase first
      await _authService.updateUserProfile(
        name: updatedUser.firstName,
        age: updatedUser.age,
        gender: updatedUser.gender,
        sports: updatedUser.sports,
        intent: updatedUser.intent,
      );
      _currentUser = updatedUser;

      
      await _saveUserToStorage();
      
      // Clear greeting cache when user info changes
      await _clearGreetingCache();
      
      notifyListeners();
    } catch (e) {
      // Fallback to local update only
      _currentUser = updatedUser;
      await _saveUserToStorage();
      await _clearGreetingCache();
      notifyListeners();
    }
  }

  // Update specific user fields
  Future<void> updateUserFields({
    String? displayName,
    String? email,
    String? phone,
    String? bio,
    String? language,
  }) async {
    if (_currentUser != null) {
      try {
        // Update local copy first
        final updatedUser = _currentUser!.copyWith(
          firstName: displayName, // Store display name as firstName
          lastName: '', // Keep lastName empty
          email: email,
          phone: phone,
          bio: bio,
          language: language,
          updatedAt: DateTime.now(),
        );
        
        // Update in Supabase using updateUserProfile
        await _authService.updateUserProfile(
          name: displayName,
        );
        
        _currentUser = updatedUser;
        
        await _saveUserToStorage();
        await _clearGreetingCache();
        notifyListeners();
      } catch (e) {
        // Fallback to local update only
        final updatedUser = _currentUser!.copyWith(
          firstName: displayName,
          lastName: '',
          email: email,
          phone: phone,
          bio: bio,
          language: language,
          updatedAt: DateTime.now(),
        );
        _currentUser = updatedUser;
        await _saveUserToStorage();
        await _clearGreetingCache();
        notifyListeners();
      }
    }
  }

  // Clear greeting cache
  Future<void> _clearGreetingCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_greetingCacheKey);
      await prefs.remove(_lastGreetingUpdateKey);
      
      _cachedGreeting = null;
      _lastGreetingUpdate = null;
    } catch (e) {
      // Handle storage error
    }
  }

  // Get user display name with fallback
  String getUserDisplayName() {
    if (_currentUser != null) {
      return _currentUser!.displayName;
    }
    return 'Player';
  }

  // Get user language preference
  String getUserLanguage() {
    return _currentUser?.language ?? 'en';
  }

  // Check if user has valid name
  bool hasValidUserName() {
    return _currentUser?.hasValidName ?? false;
  }

  // Refresh user data (simulate API call)
  Future<void> refreshUserData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, this would fetch from an API
    // For now, we'll just notify listeners to trigger a refresh
    notifyListeners();
  }

  // Clear all user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_greetingCacheKey);
      await prefs.remove(_lastGreetingUpdateKey);
      
      _currentUser = null;
      _cachedGreeting = null;
      _lastGreetingUpdate = null;
      
      notifyListeners();
    } catch (e) {
      // Handle storage error
    }
  }

  /// Clear user data when starting a new registration
  Future<void> clearUserForNewRegistration() async {
    print('🔄 [DEBUG] UserService: Clearing user data for new registration');
    await clearUserData();
  }
} 