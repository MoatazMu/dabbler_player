import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeModeKey = 'theme_mode';
  static const String _autoThemeKey = 'auto_theme_enabled';
  static const String _dayStartTimeKey = 'day_start_time';
  static const String _nightStartTimeKey = 'night_start_time';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoThemeEnabled = true;
  TimeOfDay _dayStartTime = const TimeOfDay(hour: 6, minute: 0); // 6:00 AM
  TimeOfDay _nightStartTime = const TimeOfDay(hour: 18, minute: 0); // 6:00 PM

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get autoThemeEnabled => _autoThemeEnabled;
  TimeOfDay get dayStartTime => _dayStartTime;
  TimeOfDay get nightStartTime => _nightStartTime;

  // Get effective theme mode (considering auto theme)
  ThemeMode get effectiveThemeMode {
    if (_themeMode == ThemeMode.system || _autoThemeEnabled) {
      return _getSystemThemeMode();
    }
    return _themeMode;
  }

  // Get current brightness
  Brightness get currentBrightness {
    switch (effectiveThemeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return _getSystemBrightness();
    }
  }

  // Initialize theme service
  Future<void> init() async {
    await _loadPreferences();
    notifyListeners();
  }

  // Load preferences from shared preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    // Load auto theme setting
    _autoThemeEnabled = prefs.getBool(_autoThemeKey) ?? true;
    
    // Load day start time
    final dayStartMinutes = prefs.getInt(_dayStartTimeKey) ?? 360; // 6:00 AM
    _dayStartTime = TimeOfDay(
      hour: dayStartMinutes ~/ 60,
      minute: dayStartMinutes % 60,
    );
    
    // Load night start time
    final nightStartMinutes = prefs.getInt(_nightStartTimeKey) ?? 1080; // 6:00 PM
    _nightStartTime = TimeOfDay(
      hour: nightStartMinutes ~/ 60,
      minute: nightStartMinutes % 60,
    );
  }

  // Save preferences to shared preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_themeModeKey, _themeMode.index);
    await prefs.setBool(_autoThemeKey, _autoThemeEnabled);
    await prefs.setInt(_dayStartTimeKey, _dayStartTime.hour * 60 + _dayStartTime.minute);
    await prefs.setInt(_nightStartTimeKey, _nightStartTime.hour * 60 + _nightStartTime.minute);
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _savePreferences();
      notifyListeners();
    }
  }

  // Toggle auto theme
  Future<void> setAutoThemeEnabled(bool enabled) async {
    if (_autoThemeEnabled != enabled) {
      _autoThemeEnabled = enabled;
      await _savePreferences();
      notifyListeners();
    }
  }

  // Set day start time
  Future<void> setDayStartTime(TimeOfDay time) async {
    if (_dayStartTime != time) {
      _dayStartTime = time;
      await _savePreferences();
      notifyListeners();
    }
  }

  // Set night start time
  Future<void> setNightStartTime(TimeOfDay time) async {
    if (_nightStartTime != time) {
      _nightStartTime = time;
      await _savePreferences();
      notifyListeners();
    }
  }

  // Get system theme mode based on time
  ThemeMode _getSystemThemeMode() {
    if (!_autoThemeEnabled) {
      // Use system settings
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    
    // Use time-based theme
    return _isNightTime() ? ThemeMode.dark : ThemeMode.light;
  }

  // Get system brightness
  Brightness _getSystemBrightness() {
    final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    if (_autoThemeEnabled) {
      return _isNightTime() ? Brightness.dark : Brightness.light;
    }
    
    return systemBrightness;
  }

  // Check if it's night time based on user settings
  bool _isNightTime() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final dayStartMinutes = _dayStartTime.hour * 60 + _dayStartTime.minute;
    final nightStartMinutes = _nightStartTime.hour * 60 + _nightStartTime.minute;
    
    if (dayStartMinutes < nightStartMinutes) {
      // Normal day (e.g., 6:00 AM to 6:00 PM)
      return nowMinutes < dayStartMinutes || nowMinutes >= nightStartMinutes;
    } else {
      // Overnight schedule (e.g., 6:00 PM to 6:00 AM)
      return nowMinutes >= nightStartMinutes && nowMinutes < dayStartMinutes;
    }
  }

  // Get theme description for UI
  String getThemeDescription() {
    if (_autoThemeEnabled) {
      final isDark = _isNightTime();
      return 'Auto (${isDark ? 'Dark' : 'Light'} mode)';
    }
    
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return 'System (${brightness == Brightness.dark ? 'Dark' : 'Light'} mode)';
    }
  }

  // Format time for display
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
} 