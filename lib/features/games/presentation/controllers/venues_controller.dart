import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/venue.dart';

enum VenueSortBy {
  distance,
  rating,
  price,
  name,
}

class VenueFilters {
  final List<String> sports;
  final List<String> amenities;
  final double? maxDistance; // in kilometers
  final double? minRating;
  final double? maxPricePerHour;
  final double? minPricePerHour;
  final bool openNow;
  final DateTime? availableAt;

  const VenueFilters({
    this.sports = const [],
    this.amenities = const [],
    this.maxDistance,
    this.minRating,
    this.maxPricePerHour,
    this.minPricePerHour,
    this.openNow = false,
    this.availableAt,
  });

  VenueFilters copyWith({
    List<String>? sports,
    List<String>? amenities,
    double? maxDistance,
    double? minRating,
    double? maxPricePerHour,
    double? minPricePerHour,
    bool? openNow,
    DateTime? availableAt,
  }) {
    return VenueFilters(
      sports: sports ?? this.sports,
      amenities: amenities ?? this.amenities,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      maxPricePerHour: maxPricePerHour ?? this.maxPricePerHour,
      minPricePerHour: minPricePerHour ?? this.minPricePerHour,
      openNow: openNow ?? this.openNow,
      availableAt: availableAt ?? this.availableAt,
    );
  }

  bool get hasActiveFilters {
    return sports.isNotEmpty ||
           amenities.isNotEmpty ||
           maxDistance != null ||
           minRating != null ||
           maxPricePerHour != null ||
           minPricePerHour != null ||
           openNow ||
           availableAt != null;
  }
}

class VenueWithDistance {
  final Venue venue;
  final double distanceKm;
  final bool isAvailable;
  final bool isFavorite;

  const VenueWithDistance({
    required this.venue,
    required this.distanceKm,
    required this.isAvailable,
    this.isFavorite = false,
  });

  VenueWithDistance copyWith({
    Venue? venue,
    double? distanceKm,
    bool? isAvailable,
    bool? isFavorite,
  }) {
    return VenueWithDistance(
      venue: venue ?? this.venue,
      distanceKm: distanceKm ?? this.distanceKm,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km away';
    } else {
      return '${distanceKm.round()}km away';
    }
  }

  bool get isNearby => distanceKm < 5.0;
  bool get isVeryClose => distanceKm < 1.0;
}

class VenuesState {
  final List<VenueWithDistance> venues;
  final List<Venue> favoriteVenues;
  final bool isLoading;
  final bool isLoadingFavorites;
  final String? error;
  final VenueFilters filters;
  final VenueSortBy sortBy;
  final bool ascending;
  final double? userLatitude;
  final double? userLongitude;
  final DateTime? lastUpdated;

  const VenuesState({
    this.venues = const [],
    this.favoriteVenues = const [],
    this.isLoading = false,
    this.isLoadingFavorites = false,
    this.error,
    this.filters = const VenueFilters(),
    this.sortBy = VenueSortBy.distance,
    this.ascending = true,
    this.userLatitude,
    this.userLongitude,
    this.lastUpdated,
  });

  bool get hasVenues => venues.isNotEmpty;
  bool get hasFavorites => favoriteVenues.isNotEmpty;
  bool get hasLocation => userLatitude != null && userLongitude != null;
  bool get hasError => error != null;

  List<VenueWithDistance> get nearbyVenues => 
      venues.where((v) => v.isNearby).toList();

  List<VenueWithDistance> get availableVenues => 
      venues.where((v) => v.isAvailable).toList();

  List<VenueWithDistance> get favoriteVenuesWithDistance => 
      venues.where((v) => v.isFavorite).toList();

  VenuesState copyWith({
    List<VenueWithDistance>? venues,
    List<Venue>? favoriteVenues,
    bool? isLoading,
    bool? isLoadingFavorites,
    String? error,
    VenueFilters? filters,
    VenueSortBy? sortBy,
    bool? ascending,
    double? userLatitude,
    double? userLongitude,
    DateTime? lastUpdated,
  }) {
    return VenuesState(
      venues: venues ?? this.venues,
      favoriteVenues: favoriteVenues ?? this.favoriteVenues,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      error: error,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class VenuesController extends StateNotifier<VenuesState> {
  // TODO: Add repository dependencies when available
  // final VenuesRepository _venuesRepository;
  // final BookingsRepository _bookingsRepository;
  // final UserRepository _userRepository;

  static const Duration _cacheValidity = Duration(minutes: 10);

  VenuesController() : super(const VenuesState());

  /// Set user location and load nearby venues
  Future<void> setUserLocation(double latitude, double longitude) async {
    state = state.copyWith(
      userLatitude: latitude,
      userLongitude: longitude,
    );

    await loadVenues();
  }

  /// Load venues based on current filters and location
  Future<void> loadVenues() async {
    if (!_shouldRefresh()) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(seconds: 1));

      final mockVenues = _generateMockVenues();
      
      state = state.copyWith(
        venues: mockVenues,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load venues: $e',
      );
    }
  }

  /// Update filters and reload venues
  Future<void> updateFilters(VenueFilters newFilters) async {
    state = state.copyWith(filters: newFilters);
    await loadVenues();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(filters: const VenueFilters());
    loadVenues();
  }

  /// Update sorting
  void updateSorting(VenueSortBy sortBy, {bool? ascending}) {
    state = state.copyWith(
      sortBy: sortBy,
      ascending: ascending ?? state.ascending,
    );
    _sortVenues();
  }

  /// Search venues by text
  Future<void> searchVenues(String query) async {
    if (query.isEmpty) {
      await loadVenues();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement text search in repository
      await Future.delayed(const Duration(milliseconds: 500));

      final filteredVenues = state.venues.where((venueWithDistance) {
        final venue = venueWithDistance.venue;
        return venue.name.toLowerCase().contains(query.toLowerCase()) ||
               venue.description.toLowerCase().contains(query.toLowerCase()) ||
               venue.city.toLowerCase().contains(query.toLowerCase()) ||
               venue.supportedSports.any((sport) => 
                 sport.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      state = state.copyWith(
        venues: filteredVenues,
        isLoading: false,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Check venue availability
  Future<bool> checkVenueAvailability({
    required String venueId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // TODO: Implement availability check in repository
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mock implementation - randomly return availability
      return DateTime.now().millisecond % 3 != 0;
      
    } catch (e) {
      print('Failed to check venue availability: $e');
      return false;
    }
  }

  /// Load favorite venues
  Future<void> loadFavoriteVenues() async {
    state = state.copyWith(isLoadingFavorites: true);

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock favorites
      final mockFavorites = state.venues
          .take(2)
          .map((vwd) => vwd.venue)
          .toList();

      state = state.copyWith(
        favoriteVenues: mockFavorites,
        isLoadingFavorites: false,
      );

      // Update venues list to mark favorites
      _updateFavoriteStatus();

    } catch (e) {
      state = state.copyWith(
        isLoadingFavorites: false,
        error: 'Failed to load favorites: $e',
      );
    }
  }

  /// Add venue to favorites
  Future<void> addToFavorites(String venueId) async {
    try {
      // TODO: Implement in repository
      await Future.delayed(const Duration(milliseconds: 200));

      final venue = state.venues
          .firstWhere((vwd) => vwd.venue.id == venueId)
          .venue;

      final updatedFavorites = [...state.favoriteVenues, venue];
      
      state = state.copyWith(favoriteVenues: updatedFavorites);
      _updateFavoriteStatus();

    } catch (e) {
      state = state.copyWith(error: 'Failed to add favorite: $e');
    }
  }

  /// Remove venue from favorites
  Future<void> removeFromFavorites(String venueId) async {
    try {
      // TODO: Implement in repository
      await Future.delayed(const Duration(milliseconds: 200));

      final updatedFavorites = state.favoriteVenues
          .where((venue) => venue.id != venueId)
          .toList();
      
      state = state.copyWith(favoriteVenues: updatedFavorites);
      _updateFavoriteStatus();

    } catch (e) {
      state = state.copyWith(error: 'Failed to remove favorite: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = state.copyWith(lastUpdated: null); // Force refresh
    await Future.wait([
      loadVenues(),
      loadFavoriteVenues(),
    ]);
  }

  /// Private helper methods

  bool _shouldRefresh() {
    if (state.lastUpdated == null) return true;
    return DateTime.now().difference(state.lastUpdated!) > _cacheValidity;
  }

  void _sortVenues() {
    final sortedVenues = [...state.venues];
    
    switch (state.sortBy) {
      case VenueSortBy.distance:
        sortedVenues.sort((a, b) => state.ascending
            ? a.distanceKm.compareTo(b.distanceKm)
            : b.distanceKm.compareTo(a.distanceKm));
        break;
        
      case VenueSortBy.rating:
        sortedVenues.sort((a, b) => state.ascending
            ? a.venue.rating.compareTo(b.venue.rating)
            : b.venue.rating.compareTo(a.venue.rating));
        break;
        
      case VenueSortBy.price:
        sortedVenues.sort((a, b) => state.ascending
            ? a.venue.pricePerHour.compareTo(b.venue.pricePerHour)
            : b.venue.pricePerHour.compareTo(a.venue.pricePerHour));
        break;
        
      case VenueSortBy.name:
        sortedVenues.sort((a, b) => state.ascending
            ? a.venue.name.compareTo(b.venue.name)
            : b.venue.name.compareTo(a.venue.name));
        break;
    }
    
    state = state.copyWith(venues: sortedVenues);
  }

  void _updateFavoriteStatus() {
    final favoriteIds = state.favoriteVenues.map((v) => v.id).toSet();
    
    final updatedVenues = state.venues.map((vwd) => 
        vwd.copyWith(isFavorite: favoriteIds.contains(vwd.venue.id))
    ).toList();
    
    state = state.copyWith(venues: updatedVenues);
  }

  List<VenueWithDistance> _generateMockVenues() {
    final userLat = state.userLatitude ?? 40.7831;
    final userLng = state.userLongitude ?? -73.9712;
    
    final mockVenueData = [
      {
        'name': 'Downtown Sports Center',
        'description': 'Modern sports facility with multiple courts',
        'lat': userLat + 0.01,
        'lng': userLng + 0.01,
        'sports': ['basketball', 'volleyball', 'badminton'],
        'amenities': ['parking', 'changing_rooms', 'equipment_rental'],
        'rating': 4.5,
        'price': 25.0,
      },
      {
        'name': 'Elite Fitness Club',
        'description': 'Premium fitness facility with tennis courts',
        'lat': userLat - 0.02,
        'lng': userLng + 0.015,
        'sports': ['tennis', 'squash', 'badminton'],
        'amenities': ['parking', 'changing_rooms', 'pro_shop', 'restaurant'],
        'rating': 4.8,
        'price': 45.0,
      },
      {
        'name': 'Community Recreation Center',
        'description': 'Affordable community sports facility',
        'lat': userLat + 0.03,
        'lng': userLng - 0.02,
        'sports': ['basketball', 'volleyball', 'table_tennis'],
        'amenities': ['parking', 'changing_rooms'],
        'rating': 4.1,
        'price': 15.0,
      },
      {
        'name': 'Riverside Sports Complex',
        'description': 'Large outdoor and indoor sports complex',
        'lat': userLat - 0.04,
        'lng': userLng - 0.03,
        'sports': ['football', 'soccer', 'basketball', 'tennis'],
        'amenities': ['parking', 'changing_rooms', 'equipment_rental', 'cafe'],
        'rating': 4.3,
        'price': 30.0,
      },
      {
        'name': 'Urban Court Network',
        'description': 'Network of courts across the city',
        'lat': userLat + 0.05,
        'lng': userLng + 0.04,
        'sports': ['basketball', 'tennis', 'volleyball'],
        'amenities': ['changing_rooms', 'equipment_rental'],
        'rating': 4.0,
        'price': 20.0,
      },
    ];

    return mockVenueData.map((data) {
      final venue = Venue(
        id: 'venue_${data['name'].toString().toLowerCase().replaceAll(' ', '_')}',
        name: data['name'] as String,
        description: data['description'] as String,
        addressLine1: '${data['name']} Address',
        city: 'New York',
        state: 'NY',
        country: 'USA',
        postalCode: '10001',
        latitude: data['lat'] as double,
        longitude: data['lng'] as double,
        openingTime: '06:00',
        closingTime: '22:00',
        rating: data['rating'] as double,
        totalRatings: 50 + DateTime.now().millisecond % 200,
        pricePerHour: data['price'] as double,
        currency: 'USD',
        supportedSports: data['sports'] as List<String>,
        amenities: data['amenities'] as List<String>,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      final distance = _calculateDistance(
        userLat, userLng,
        data['lat'] as double, data['lng'] as double,
      );

      return VenueWithDistance(
        venue: venue,
        distanceKm: distance,
        isAvailable: DateTime.now().millisecond % 3 != 0, // Random availability
        isFavorite: false, // Will be updated by _updateFavoriteStatus
      );
    }).toList();
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = 
        (dLat / 2).abs() * (dLat / 2).abs() + 
        (lat1 * 3.14159 / 180).abs() * (lat2 * 3.14159 / 180).abs() * 
        (dLng / 2).abs() * (dLng / 2).abs();
        
    final double c = 2 * (a.abs() + (1 - a).abs());
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159 / 180);
  }
}
