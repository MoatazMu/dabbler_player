import 'dart:async';
import 'dart:math';

enum LocationStatus {
  loading,
  success,
  permissionDenied,
  serviceDisabled,
  timeout,
  error,
  manualSelection,
}

class LocationData {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final LocationStatus status;
  final String? errorMessage;
  final DateTime timestamp;

  LocationData({
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    required this.status,
    this.errorMessage,
  }) : timestamp = DateTime.now();

  String get displayName {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (address != null) {
      return address!;
    } else if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    } else {
      return 'Unknown Location';
    }
  }

  bool get isValid => status == LocationStatus.success || status == LocationStatus.manualSelection;

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    LocationStatus? status,
    String? errorMessage,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  final StreamController<LocationData> _locationController = StreamController<LocationData>.broadcast();
  Stream<LocationData> get locationStream => _locationController.stream;

  LocationData? _currentLocation;
  LocationData? get currentLocation => _currentLocation;

  Timer? _debounceTimer;
  Timer? _simulationTimer;
  bool _isLocationEnabled = true;
  bool _hasLocationPermission = true;
  
  // Simulation flags for testing
  bool _simulatePermissionDenied = false;
  bool _simulateGPSDisabled = false;
  bool _simulateTimeout = false;
  bool _simulateError = false;
  bool _simulateRapidMovement = false;
  
  // Debounce settings
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _locationUpdateInterval = Duration(seconds: 2);

  // Mock locations for testing
  static final List<LocationData> _mockLocations = [
    LocationData(
      latitude: 25.2048,
      longitude: 55.2708,
      address: 'Dubai Mall, Downtown Dubai',
      city: 'Dubai',
      country: 'UAE',
      status: LocationStatus.success,
    ),
    LocationData(
      latitude: 25.1972,
      longitude: 55.2744,
      address: 'Burj Khalifa, Downtown Dubai',
      city: 'Dubai',
      country: 'UAE',
      status: LocationStatus.success,
    ),
    LocationData(
      latitude: 25.2582,
      longitude: 55.3047,
      address: 'Dubai International Airport',
      city: 'Dubai',
      country: 'UAE',
      status: LocationStatus.success,
    ),
  ];

  /// Start location detection
  Future<LocationData> detectLocation() async {
    _updateLocationData(LocationData(status: LocationStatus.loading));
    
    // Simulate various failure scenarios for testing
    if (_simulatePermissionDenied) {
      await Future.delayed(const Duration(milliseconds: 500));
      final errorLocation = LocationData(
        status: LocationStatus.permissionDenied,
        errorMessage: 'Location permission denied',
      );
      _updateLocationData(errorLocation);
      return errorLocation;
    }

    if (_simulateGPSDisabled) {
      await Future.delayed(const Duration(milliseconds: 800));
      final errorLocation = LocationData(
        status: LocationStatus.serviceDisabled,
        errorMessage: 'GPS service disabled',
      );
      _updateLocationData(errorLocation);
      return errorLocation;
    }

    if (_simulateTimeout) {
      await Future.delayed(const Duration(seconds: 10));
      final errorLocation = LocationData(
        status: LocationStatus.timeout,
        errorMessage: 'Location detection timeout',
      );
      _updateLocationData(errorLocation);
      return errorLocation;
    }

    if (_simulateError) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final errorLocation = LocationData(
        status: LocationStatus.error,
        errorMessage: 'Failed to detect location',
      );
      _updateLocationData(errorLocation);
      return errorLocation;
    }

    // Simulate successful location detection
    await Future.delayed(const Duration(milliseconds: 1500));
    final random = Random();
    final mockLocation = _mockLocations[random.nextInt(_mockLocations.length)];
    
    // Add slight variation to coordinates for testing
    final location = mockLocation.copyWith(
      latitude: mockLocation.latitude! + (random.nextDouble() - 0.5) * 0.01,
      longitude: mockLocation.longitude! + (random.nextDouble() - 0.5) * 0.01,
    );
    
    _updateLocationData(location);
    
    // Start rapid movement simulation if enabled
    if (_simulateRapidMovement) {
      _startRapidMovementSimulation();
    }
    
    return location;
  }

  /// Update location data with debouncing
  void _updateLocationData(LocationData location) {
    _currentLocation = location;
    
    // Cancel previous debounce timer
    _debounceTimer?.cancel();
    
    // Set new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _locationController.add(location);
    });
  }

  /// Simulate rapid movement or changing GPS coordinates
  void _startRapidMovementSimulation() {
    _simulationTimer?.cancel();
    
    final random = Random();
    final baseLocation = _currentLocation!;
    
    _simulationTimer = Timer.periodic(_locationUpdateInterval, (timer) {
      if (!_simulateRapidMovement) {
        timer.cancel();
        return;
      }
      
      // Generate new coordinates around the base location
      final newLat = baseLocation.latitude! + (random.nextDouble() - 0.5) * 0.02;
      final newLng = baseLocation.longitude! + (random.nextDouble() - 0.5) * 0.02;
      
      final newLocation = baseLocation.copyWith(
        latitude: newLat,
        longitude: newLng,
      );
      
      _updateLocationData(newLocation);
    });
  }

  /// Manually set location (for user input)
  Future<LocationData> setManualLocation(String locationInput) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (locationInput.trim().isEmpty) {
      final errorLocation = LocationData(
        status: LocationStatus.error,
        errorMessage: 'Invalid location input',
      );
      _updateLocationData(errorLocation);
      return errorLocation;
    }
    
    // Simulate geocoding
    final location = LocationData(
      address: locationInput.trim(),
      city: _extractCityFromInput(locationInput),
      country: 'UAE', // Default for simulation
      status: LocationStatus.manualSelection,
    );
    
    _updateLocationData(location);
    return location;
  }

  /// Extract city name from location input (simplified)
  String? _extractCityFromInput(String input) {
    final cleaned = input.trim().toLowerCase();
    if (cleaned.contains('dubai')) return 'Dubai';
    if (cleaned.contains('abu dhabi')) return 'Abu Dhabi';
    if (cleaned.contains('sharjah')) return 'Sharjah';
    return null;
  }

  /// Retry location detection
  Future<LocationData> retryLocationDetection() async {
    // Reset error flags for retry
    _simulateError = false;
    _simulateTimeout = false;
    
    return detectLocation();
  }

  /// Check if location services are enabled
  bool get isLocationServiceEnabled => _isLocationEnabled && !_simulateGPSDisabled;

  /// Check if location permission is granted
  bool get hasLocationPermission => _hasLocationPermission && !_simulatePermissionDenied;

  /// Enable/disable location services (for testing)
  void setLocationServiceEnabled(bool enabled) {
    _isLocationEnabled = enabled;
  }

  /// Grant/deny location permission (for testing)
  void setLocationPermission(bool granted) {
    _hasLocationPermission = granted;
  }

  // Testing simulation methods
  void simulatePermissionDenied(bool simulate) {
    _simulatePermissionDenied = simulate;
  }

  void simulateGPSDisabled(bool simulate) {
    _simulateGPSDisabled = simulate;
  }

  void simulateTimeout(bool simulate) {
    _simulateTimeout = simulate;
  }

  void simulateError(bool simulate) {
    _simulateError = simulate;
  }

  void simulateRapidMovement(bool simulate) {
    _simulateRapidMovement = simulate;
    if (!simulate) {
      _simulationTimer?.cancel();
    }
  }

  /// Reset all simulation flags
  void resetSimulation() {
    _simulatePermissionDenied = false;
    _simulateGPSDisabled = false;
    _simulateTimeout = false;
    _simulateError = false;
    _simulateRapidMovement = false;
    _simulationTimer?.cancel();
  }

  /// Get location status message
  String getStatusMessage(LocationStatus status, String language) {
    switch (status) {
      case LocationStatus.loading:
        return language == 'ar' ? 'جاري تحديد موقعك...' : 'Finding your location...';
      case LocationStatus.success:
        return language == 'ar' ? 'تم تحديد الموقع بنجاح' : 'Location detected successfully';
      case LocationStatus.permissionDenied:
        return language == 'ar' ? 'تم رفض الوصول للموقع' : 'Location access denied';
      case LocationStatus.serviceDisabled:
        return language == 'ar' ? 'خدمة الموقع معطلة' : 'Location service disabled';
      case LocationStatus.timeout:
        return language == 'ar' ? 'انتهت مهلة تحديد الموقع' : 'Location detection timeout';
      case LocationStatus.error:
        return language == 'ar' ? 'لا يمكن تحديد الموقع' : 'Unable to detect location';
      case LocationStatus.manualSelection:
        return language == 'ar' ? 'تم تحديد الموقع يدوياً' : 'Location set manually';
    }
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _simulationTimer?.cancel();
    _locationController.close();
  }
}