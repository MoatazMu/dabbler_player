import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/controllers/games_controller.dart';
import '../presentation/controllers/create_game_controller.dart';
import '../presentation/controllers/game_detail_controller.dart';
import '../presentation/controllers/venues_controller.dart';
import '../presentation/controllers/my_games_controller.dart';
import '../domain/usecases/find_games_usecase.dart';
import '../domain/usecases/create_game_usecase.dart';
import '../domain/usecases/join_game_usecase.dart';
import '../domain/usecases/cancel_game_usecase.dart';
import '../domain/entities/game.dart';
import '../domain/entities/venue.dart';

// =============================================================================
// REPOSITORY PROVIDERS
// =============================================================================

// TODO: Implement these when repositories are available
final gamesRepositoryProvider = Provider((ref) {
  throw UnimplementedError('GamesRepository not implemented yet');
});

final venuesRepositoryProvider = Provider((ref) {
  throw UnimplementedError('VenuesRepository not implemented yet');
});

final bookingsRepositoryProvider = Provider((ref) {
  throw UnimplementedError('BookingsRepository not implemented yet');
});

// =============================================================================
// USE CASE PROVIDERS
// =============================================================================

final findGamesUseCaseProvider = Provider<FindGamesUseCase>((ref) {
  return FindGamesUseCase(
    gamesRepository: ref.watch(gamesRepositoryProvider),
  );
});

final createGameUseCaseProvider = Provider<CreateGameUseCase>((ref) {
  return CreateGameUseCase(
    gamesRepository: ref.watch(gamesRepositoryProvider),
    venuesRepository: ref.watch(venuesRepositoryProvider),
    bookingsRepository: ref.watch(bookingsRepositoryProvider),
  );
});

final joinGameUseCaseProvider = Provider<JoinGameUseCase>((ref) {
  return JoinGameUseCase(
    gamesRepository: ref.watch(gamesRepositoryProvider),
  );
});

final cancelGameUseCaseProvider = Provider<CancelGameUseCase>((ref) {
  return CancelGameUseCase(
    gamesRepository: ref.watch(gamesRepositoryProvider),
    bookingsRepository: ref.watch(bookingsRepositoryProvider),
  );
});

// =============================================================================
// CONTROLLER PROVIDERS
// =============================================================================

/// Main games controller for discovering and browsing games
final gamesControllerProvider = StateNotifierProvider<GamesController, GamesState>((ref) {
  return GamesController(
    findGamesUseCase: ref.watch(findGamesUseCaseProvider),
  );
});

/// Create game controller for multi-step game creation
final createGameControllerProvider = StateNotifierProvider<CreateGameController, CreateGameState>((ref) {
  return CreateGameController(
    createGameUseCase: ref.watch(createGameUseCaseProvider),
  );
});

/// Venues controller for venue discovery and management
final venuesControllerProvider = StateNotifierProvider<VenuesController, VenuesState>((ref) {
  return VenuesController();
});

/// My games controller for user's personal game management
final myGamesControllerProvider = StateNotifierProvider.family<MyGamesController, MyGamesState, String>((ref, userId) {
  return MyGamesController(
    cancelGameUseCase: ref.watch(cancelGameUseCaseProvider),
    userId: userId,
  );
});

/// Game detail controller for individual game management (family provider for different games)
final gameDetailControllerProvider = StateNotifierProvider.family<GameDetailController, GameDetailState, GameDetailParams>((ref, params) {
  return GameDetailController(
    joinGameUseCase: ref.watch(joinGameUseCaseProvider),
    gameId: params.gameId,
    currentUserId: params.currentUserId,
  );
});

// =============================================================================
// CONVENIENCE PROVIDERS
// =============================================================================

/// Current user's games
final myGamesProvider = Provider.family<MyGamesController, String>((ref, userId) {
  return ref.watch(myGamesControllerProvider(userId).notifier);
});

/// Nearby games based on current location
final nearbyGamesProvider = Provider((ref) {
  final gamesState = ref.watch(gamesControllerProvider);
  return gamesState.nearbyGames;
});

/// Upcoming games from all sources
final upcomingGamesProvider = Provider((ref) {
  final gamesState = ref.watch(gamesControllerProvider);
  return gamesState.upcomingGames;
});

/// Today's games for current user
final todayGamesProvider = Provider.family<List<Game>, String>((ref, userId) {
  final myGamesState = ref.watch(myGamesControllerProvider(userId));
  return myGamesState.todayGames;
});

/// This week's games for current user
final thisWeekGamesProvider = Provider.family<List<Game>, String>((ref, userId) {
  final myGamesState = ref.watch(myGamesControllerProvider(userId));
  return myGamesState.thisWeekGames;
});

/// Active check-in reminders
final activeRemindersProvider = Provider.family<List<CheckInReminder>, String>((ref, userId) {
  final myGamesState = ref.watch(myGamesControllerProvider(userId));
  return myGamesState.checkInReminders.where((r) => r.isActive && r.shouldShowReminder).toList();
});

/// User's game statistics
final gameStatisticsProvider = Provider.family<GameStatistics?, String>((ref, userId) {
  final myGamesState = ref.watch(myGamesControllerProvider(userId));
  return myGamesState.statistics;
});

/// Available venues near user
final nearbyVenuesProvider = Provider((ref) {
  final venuesState = ref.watch(venuesControllerProvider);
  return venuesState.nearbyVenues;
});

/// User's favorite venues
final favoriteVenuesProvider = Provider((ref) {
  final venuesState = ref.watch(venuesControllerProvider);
  return venuesState.favoriteVenues;
});

/// Available venues (only those that are currently available)
final availableVenuesProvider = Provider((ref) {
  final venuesState = ref.watch(venuesControllerProvider);
  return venuesState.availableVenues;
});

/// Games loading state (true if any games are loading)
final gamesLoadingProvider = Provider((ref) {
  final gamesState = ref.watch(gamesControllerProvider);
  return gamesState.isLoading;
});

/// Venues loading state
final venuesLoadingProvider = Provider((ref) {
  final venuesState = ref.watch(venuesControllerProvider);
  return venuesState.isLoading;
});

/// Current game filters
final currentFiltersProvider = Provider((ref) {
  final gamesState = ref.watch(gamesControllerProvider);
  return gamesState.filters;
});

/// Current venue filters
final currentVenueFiltersProvider = Provider((ref) {
  final venuesState = ref.watch(venuesControllerProvider);
  return venuesState.filters;
});

// =============================================================================
// SPECIFIC GAME PROVIDERS
// =============================================================================

/// Specific game detail by ID
final gameByIdProvider = Provider.family<Game?, String>((ref, gameId) {
  final gamesState = ref.watch(gamesControllerProvider);
  
  // Search in all game lists
  for (final game in [...gamesState.upcomingGames, ...gamesState.nearbyGames, ...gamesState.allGames]) {
    if (game.id == gameId) return game;
  }
  
  return null;
});

/// Venue detail by ID
final venueByIdProvider = Provider.family<Venue?, String>((ref, venueId) {
  final venuesState = ref.watch(venuesControllerProvider);
  
  for (final venueWithDistance in venuesState.venues) {
    if (venueWithDistance.venue.id == venueId) {
      return venueWithDistance.venue;
    }
  }
  
  return null;
});

/// Games organized by specific user
final gamesByOrganizerProvider = Provider.family<List<Game>, String>((ref, organizerId) {
  final gamesState = ref.watch(gamesControllerProvider);
  
  return [
    ...gamesState.upcomingGames.where((g) => g.organizerId == organizerId),
    ...gamesState.allGames.where((g) => g.organizerId == organizerId),
  ];
});

/// Games by sport
final gamesBySportProvider = Provider.family<List<Game>, String>((ref, sport) {
  final gamesState = ref.watch(gamesControllerProvider);
  
  return [
    ...gamesState.upcomingGames.where((g) => g.sport.toLowerCase() == sport.toLowerCase()),
    ...gamesState.allGames.where((g) => g.sport.toLowerCase() == sport.toLowerCase()),
  ];
});

/// Venues by sport
final venuesBySportProvider = Provider.family<List<VenueWithDistance>, String>((ref, sport) {
  final venuesState = ref.watch(venuesControllerProvider);
  
  return venuesState.venues.where((vwd) => 
    vwd.venue.supportedSports.any((s) => s.toLowerCase() == sport.toLowerCase())
  ).toList();
});

// =============================================================================
// ACTION PROVIDERS (for UI to call controller methods)
// =============================================================================

/// Games actions provider
final gamesActionsProvider = Provider((ref) {
  return GamesActions(ref);
});

/// Venues actions provider  
final venuesActionsProvider = Provider((ref) {
  return VenuesActions(ref);
});

/// My games actions provider
final myGamesActionsProvider = Provider.family<MyGamesActions, String>((ref, userId) {
  return MyGamesActions(ref, userId);
});

/// Create game actions provider
final createGameActionsProvider = Provider((ref) {
  return CreateGameActions(ref);
});

// =============================================================================
// SUPPORTING CLASSES
// =============================================================================

/// Parameters for game detail controller
class GameDetailParams {
  final String gameId;
  final String? currentUserId;

  const GameDetailParams({
    required this.gameId,
    this.currentUserId,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is GameDetailParams &&
    runtimeType == other.runtimeType &&
    gameId == other.gameId &&
    currentUserId == other.currentUserId;

  @override
  int get hashCode => gameId.hashCode ^ currentUserId.hashCode;
}

/// Action wrapper classes for easier UI integration
class GamesActions {
  final Ref _ref;
  GamesActions(this._ref);

  Future<void> loadGames({GameListType type = GameListType.all}) async {
    await _ref.read(gamesControllerProvider.notifier).loadGames(type: type);
  }

  Future<void> refreshGames() async {
    await _ref.read(gamesControllerProvider.notifier).refreshGames();
  }

  Future<void> updateFilters(GameFilters filters) async {
    await _ref.read(gamesControllerProvider.notifier).updateFilters(filters);
  }

  Future<void> setUserLocation(double latitude, double longitude) async {
    await _ref.read(gamesControllerProvider.notifier).setUserLocation(latitude, longitude);
  }

  Future<void> loadMore() async {
    await _ref.read(gamesControllerProvider.notifier).loadMore();
  }

  void clearFilters() {
    _ref.read(gamesControllerProvider.notifier).clearFilters();
  }
}

class VenuesActions {
  final Ref _ref;
  VenuesActions(this._ref);

  Future<void> loadVenues() async {
    await _ref.read(venuesControllerProvider.notifier).loadVenues();
  }

  Future<void> setUserLocation(double latitude, double longitude) async {
    await _ref.read(venuesControllerProvider.notifier).setUserLocation(latitude, longitude);
  }

  Future<void> updateFilters(VenueFilters filters) async {
    await _ref.read(venuesControllerProvider.notifier).updateFilters(filters);
  }

  Future<void> searchVenues(String query) async {
    await _ref.read(venuesControllerProvider.notifier).searchVenues(query);
  }

  Future<void> addToFavorites(String venueId) async {
    await _ref.read(venuesControllerProvider.notifier).addToFavorites(venueId);
  }

  Future<void> removeFromFavorites(String venueId) async {
    await _ref.read(venuesControllerProvider.notifier).removeFromFavorites(venueId);
  }

  Future<void> refresh() async {
    await _ref.read(venuesControllerProvider.notifier).refresh();
  }
}

class MyGamesActions {
  final Ref _ref;
  final String _userId;
  MyGamesActions(this._ref, this._userId);

  Future<void> refresh() async {
    await _ref.read(myGamesControllerProvider(_userId).notifier).refresh();
  }

  Future<void> cancelGame(String gameId, String reason) async {
    await _ref.read(myGamesControllerProvider(_userId).notifier).cancelGame(gameId, reason);
  }

  Future<String> shareGame(String gameId) async {
    return await _ref.read(myGamesControllerProvider(_userId).notifier).shareGame(gameId);
  }

  Future<void> checkInToGame(String gameId) async {
    await _ref.read(myGamesControllerProvider(_userId).notifier).checkInToGame(gameId);
  }

  Future<void> executeQuickAction(QuickAction action, String gameId) async {
    await _ref.read(myGamesControllerProvider(_userId).notifier).executeQuickAction(action, gameId);
  }
}

class CreateGameActions {
  final Ref _ref;
  CreateGameActions(this._ref);

  void selectSport(String sport) {
    _ref.read(createGameControllerProvider.notifier).selectSport(sport);
  }

  void setDateTime({DateTime? date, String? startTime, String? endTime}) {
    _ref.read(createGameControllerProvider.notifier).setDateTime(
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }

  void selectVenue(Venue? venue) {
    _ref.read(createGameControllerProvider.notifier).selectVenue(venue);
  }

  void configureGame({
    String? title,
    String? description,
    String? skillLevel,
    double? pricePerPlayer,
    bool? isPublic,
    bool? allowWaitlist,
  }) {
    _ref.read(createGameControllerProvider.notifier).configureGame(
      title: title,
      description: description,
      skillLevel: skillLevel,
      pricePerPlayer: pricePerPlayer,
      isPublic: isPublic,
      allowWaitlist: allowWaitlist,
    );
  }

  void configurePlayerSettings({int? minPlayers, int? maxPlayers}) {
    _ref.read(createGameControllerProvider.notifier).configurePlayerSettings(
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
  }

  void nextStep() {
    _ref.read(createGameControllerProvider.notifier).nextStep();
  }

  void previousStep() {
    _ref.read(createGameControllerProvider.notifier).previousStep();
  }

  void goToStep(CreateGameStep step) {
    _ref.read(createGameControllerProvider.notifier).goToStep(step);
  }

  Future<void> reviewAndCreate(String organizerId) async {
    await _ref.read(createGameControllerProvider.notifier).reviewAndCreate(organizerId);
  }

  void reset() {
    _ref.read(createGameControllerProvider.notifier).reset();
  }
}
