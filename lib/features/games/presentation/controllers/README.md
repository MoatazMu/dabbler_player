# Games State Management Implementation

This document outlines the comprehensive state management implementation for the games feature using Riverpod with StateNotifier pattern.

## Architecture Overview

The implementation follows a clean architecture with:
- **Controllers**: StateNotifier classes managing specific feature state
- **Providers**: Riverpod providers for dependency injection and state access
- **Use Cases**: Business logic integration through domain use cases
- **Real-time Updates**: Timer-based polling for live data updates

## 🎮 Controllers Implementation

### 1. GamesController (`games_controller.dart`)

**Purpose**: Main controller for game discovery and browsing

**State Management**:
```dart
class GamesState {
  final List<Game> upcomingGames;      // Games starting soon
  final List<Game> nearbyGames;        // Location-based games
  final List<Game> allGames;           // All discovered games
  final bool isLoadingUpcoming;        // Loading states per section
  final bool isLoadingNearby;
  final bool isLoadingAll;
  final bool isRefreshing;             // Global refresh state
  final String? error;                 // Error messages
  final GameFilters filters;           // Current search filters
  final PaginationInfo? paginationInfo; // Pagination support
  final DateTime? lastUpdated;         // Cache management
}
```

**Key Features**:
- **Location-Based Search**: Distance calculation using Haversine formula
- **Smart Caching**: 5-minute cache validity with automatic refresh detection
- **Pagination**: Load more functionality with proper state management
- **Real-time Updates**: WebSocket subscription hooks (implementation ready)
- **Multi-source Loading**: Concurrent loading of different game types

**Main Methods**:
- `loadGames()` - Load games with filtering and pagination
- `refreshGames()` - Force refresh all game lists
- `updateFilters()` - Apply new search filters
- `setUserLocation()` - Enable location-based search
- `loadMore()` - Pagination support

### 2. CreateGameController (`create_game_controller.dart`)

**Purpose**: Multi-step game creation flow management

**State Management**:
```dart
enum CreateGameStep {
  sportSelection,    // Step 1: Choose sport
  dateTimeSetup,     // Step 2: Set date and time
  venueSelection,    // Step 3: Select venue (optional)
  gameConfiguration, // Step 4: Configure game details
  playerSettings,    // Step 5: Set player limits
  reviewAndCreate,   // Step 6: Final review and creation
}

class CreateGameState {
  final CreateGameStep currentStep;
  final Map<String, String?> validationErrors; // Per-field validation
  final bool isLoading;
  final bool isCreated;
  // Step-specific data...
  final String? selectedSport;
  final DateTime? selectedDate;
  final Venue? selectedVenue;
  final double? estimatedCost;        // Dynamic cost calculation
}
```

**Key Features**:
- **Step-by-Step Validation**: Comprehensive validation at each step
- **Progress Tracking**: Visual progress with step indicators
- **Cost Estimation**: Real-time cost calculation based on venue and duration
- **Sport-Specific Logic**: Player limits and rules per sport type
- **Venue Integration**: Nearby venue loading and selection
- **Form State Persistence**: Maintains data across step navigation

**Main Methods**:
- `selectSport()` - Step 1: Sport selection with validation
- `setDateTime()` - Step 2: Date/time with business rules
- `selectVenue()` - Step 3: Venue selection (optional)
- `configureGame()` - Step 4: Game details and pricing
- `configurePlayerSettings()` - Step 5: Player limits with sport rules
- `reviewAndCreate()` - Step 6: Final validation and creation
- `nextStep()/previousStep()` - Navigation control

### 3. GameDetailController (`game_detail_controller.dart`)

**Purpose**: Individual game management with real-time updates

**State Management**:
```dart
class GameDetailState {
  final Game? game;                    // Game details
  final Venue? venue;                  // Venue information
  final List<Player> players;          // Current players
  final List<Player> waitlistedPlayers; // Waitlisted players
  final JoinGameStatus joinStatus;     // User's join eligibility
  final WeatherInfo? weather;          // Weather forecast
  final bool isOrganizer;             // User permissions
  final DateTime? lastUpdated;         // Real-time update tracking
}
```

**Key Features**:
- **Real-time Player Updates**: 30-second polling for player changes
- **Join Status Management**: Dynamic eligibility calculation
- **Weather Integration**: Location-based weather forecasts
- **Multi-loading States**: Separate loading for game, venue, players, weather
- **Smart Join Logic**: Waitlist handling and timing restrictions
- **Share Functionality**: Formatted game sharing

**Main Methods**:
- `joinGame()` - Join game with eligibility checking
- `leaveGame()` - Leave game with proper cleanup
- `refresh()` - Manual refresh of all data
- `getShareableGameInfo()` - Generate shareable content

### 4. VenuesController (`venues_controller.dart`)

**Purpose**: Venue discovery and management

**State Management**:
```dart
class VenuesState {
  final List<VenueWithDistance> venues; // Venues with distance data
  final List<Venue> favoriteVenues;     // User's favorite venues
  final VenueFilters filters;           // Search filters
  final VenueSortBy sortBy;             // Sorting preference
  final double? userLatitude;           // User location
  final double? userLongitude;
}
```

**Key Features**:
- **Distance Calculation**: Haversine formula for accurate distances
- **Advanced Filtering**: Sports, amenities, price, rating, availability
- **Favorite Management**: Persistent favorite venue tracking
- **Availability Checking**: Real-time venue booking availability
- **Smart Sorting**: Distance, rating, price, alphabetical
- **Search Functionality**: Text-based venue search

**Main Methods**:
- `setUserLocation()` - Enable location-based features
- `updateFilters()` - Apply search filters
- `searchVenues()` - Text search functionality
- `checkVenueAvailability()` - Availability verification
- `addToFavorites()/removeFromFavorites()` - Favorite management

### 5. MyGamesController (`my_games_controller.dart`)

**Purpose**: User's personal game management

**State Management**:
```dart
class MyGamesState {
  final List<Game> upcomingGames;       // User's upcoming games
  final List<Game> pastGames;           // Game history
  final List<Game> organizedGames;      // Games organized by user
  final List<Game> joinedGames;         // Games joined by user
  final GameStatistics? statistics;     // User's game statistics
  final List<CheckInReminder> checkInReminders; // Active reminders
  final Timer? reminderTimer;           // Reminder system
}
```

**Key Features**:
- **Game Statistics**: Comprehensive analytics (games played, ratings, etc.)
- **Check-in Reminders**: Smart reminders 2 hours before games
- **Quick Actions**: Cancel, share, check-in, rate functionality
- **Game History**: Complete game participation history
- **Real-time Reminders**: Minute-by-minute reminder updates
- **Action Validation**: Context-aware action availability

**Main Methods**:
- `cancelGame()` - Cancel organized games with notifications
- `shareGame()` - Generate shareable game content
- `checkInToGame()` - Quick check-in functionality
- `executeQuickAction()` - Context-aware action execution
- `getAvailableActions()` - Dynamic action menu generation

## 🔌 Providers Architecture (`games_providers.dart`)

### Repository Providers (TODO)
```dart
final gamesRepositoryProvider = Provider((ref) => ...);
final venuesRepositoryProvider = Provider((ref) => ...);
final bookingsRepositoryProvider = Provider((ref) => ...);
```

### Use Case Providers
```dart
final findGamesUseCaseProvider = Provider<FindGamesUseCase>((ref) => ...);
final createGameUseCaseProvider = Provider<CreateGameUseCase>((ref) => ...);
final joinGameUseCaseProvider = Provider<JoinGameUseCase>((ref) => ...);
final cancelGameUseCaseProvider = Provider<CancelGameUseCase>((ref) => ...);
```

### Controller Providers
```dart
// Main controllers
final gamesControllerProvider = StateNotifierProvider<GamesController, GamesState>((ref) => ...);
final createGameControllerProvider = StateNotifierProvider<CreateGameController, CreateGameState>((ref) => ...);
final venuesControllerProvider = StateNotifierProvider<VenuesController, VenuesState>((ref) => ...);

// Family providers for user-specific or parameterized controllers
final myGamesControllerProvider = StateNotifierProvider.family<MyGamesController, MyGamesState, String>((ref, userId) => ...);
final gameDetailControllerProvider = StateNotifierProvider.family<GameDetailController, GameDetailState, GameDetailParams>((ref, params) => ...);
```

### Convenience Providers
```dart
// Current user's data
final myGamesProvider = Provider.family<MyGamesController, String>((ref, userId) => ...);
final todayGamesProvider = Provider.family<List<Game>, String>((ref, userId) => ...);
final activeRemindersProvider = Provider.family<List<CheckInReminder>, String>((ref, userId) => ...);

// Global data access
final nearbyGamesProvider = Provider((ref) => ...);
final upcomingGamesProvider = Provider((ref) => ...);
final nearbyVenuesProvider = Provider((ref) => ...);

// Filtered data
final gamesBySportProvider = Provider.family<List<Game>, String>((ref, sport) => ...);
final venuesBySportProvider = Provider.family<List<VenueWithDistance>, String>((ref, sport) => ...);
```

### Action Providers (UI Helpers)
```dart
final gamesActionsProvider = Provider((ref) => GamesActions(ref));
final venuesActionsProvider = Provider((ref) => VenuesActions(ref));
final myGamesActionsProvider = Provider.family<MyGamesActions, String>((ref, userId) => ...);
final createGameActionsProvider = Provider((ref) => CreateGameActions(ref));
```

## 🎯 Usage Examples

### Basic Game Loading
```dart
class GamesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesState = ref.watch(gamesControllerProvider);
    final gamesActions = ref.read(gamesActionsProvider);
    
    return RefreshIndicator(
      onRefresh: gamesActions.refreshGames,
      child: ListView.builder(
        itemCount: gamesState.upcomingGames.length,
        itemBuilder: (context, index) {
          final game = gamesState.upcomingGames[index];
          return GameCard(game: game);
        },
      ),
    );
  }
}
```

### Location-Based Search
```dart
// Enable location-based features
await ref.read(gamesActionsProvider).setUserLocation(latitude, longitude);
await ref.read(venuesActionsProvider).setUserLocation(latitude, longitude);

// Access nearby data
final nearbyGames = ref.watch(nearbyGamesProvider);
final nearbyVenues = ref.watch(nearbyVenuesProvider);
```

### Game Creation Flow
```dart
class CreateGameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createGameControllerProvider);
    final createActions = ref.read(createGameActionsProvider);
    
    return Scaffold(
      body: Column(
        children: [
          LinearProgressIndicator(value: createState.progress),
          Expanded(
            child: _buildStepContent(createState.currentStep),
          ),
          Row(
            children: [
              if (!createState.isFirstStep)
                ElevatedButton(
                  onPressed: createActions.previousStep,
                  child: Text('Previous'),
                ),
              if (!createState.isLastStep)
                ElevatedButton(
                  onPressed: createState.canProceedToNext 
                    ? createActions.nextStep 
                    : null,
                  child: Text('Next'),
                ),
              if (createState.isLastStep)
                ElevatedButton(
                  onPressed: () => createActions.reviewAndCreate(userId),
                  child: Text('Create Game'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### My Games with Actions
```dart
class MyGamesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGamesState = ref.watch(myGamesControllerProvider(userId));
    final myGamesActions = ref.read(myGamesActionsProvider(userId));
    
    return ListView.builder(
      itemCount: myGamesState.upcomingGames.length,
      itemBuilder: (context, index) {
        final game = myGamesState.upcomingGames[index];
        final availableActions = ref
            .read(myGamesControllerProvider(userId).notifier)
            .getAvailableActions(game);
            
        return GameCard(
          game: game,
          actions: availableActions.map((action) => 
            ActionButton(
              icon: _getActionIcon(action),
              onPressed: () => myGamesActions.executeQuickAction(action, game.id),
            ),
          ).toList(),
        );
      },
    );
  }
}
```

### Real-time Game Details
```dart
class GameDetailScreen extends ConsumerWidget {
  final String gameId;
  final String? userId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameDetailState = ref.watch(gameDetailControllerProvider(
      GameDetailParams(gameId: gameId, currentUserId: userId)
    ));
    
    if (gameDetailState.isLoading) {
      return LoadingScreen();
    }
    
    return Scaffold(
      body: Column(
        children: [
          GameHeader(game: gameDetailState.game),
          if (gameDetailState.hasVenue)
            VenueCard(venue: gameDetailState.venue),
          if (gameDetailState.hasWeather)
            WeatherCard(weather: gameDetailState.weather),
          PlayersList(
            players: gameDetailState.players,
            waitlistedPlayers: gameDetailState.waitlistedPlayers,
          ),
          JoinButton(
            status: gameDetailState.joinStatus,
            onJoin: () => ref
                .read(gameDetailControllerProvider(GameDetailParams(gameId: gameId, currentUserId: userId)).notifier)
                .joinGame(),
          ),
        ],
      ),
    );
  }
}
```

## 🔄 Real-time Updates

### Automatic Updates
- **Games Controller**: WebSocket subscription hooks (ready for implementation)
- **Game Detail Controller**: 30-second polling for player updates
- **My Games Controller**: 1-minute reminder checking
- **Venues Controller**: 10-minute cache validity

### Manual Refresh
```dart
// Refresh all games data
await ref.read(gamesActionsProvider).refreshGames();

// Refresh user's games
await ref.read(myGamesActionsProvider(userId)).refresh();

// Refresh venues
await ref.read(venuesActionsProvider).refresh();
```

## 🎨 State Management Benefits

### Performance
- **Smart Caching**: Prevents unnecessary API calls
- **Pagination**: Efficient loading of large datasets
- **Selective Loading**: Load only what's needed when needed
- **Real-time Efficiency**: Targeted updates only when relevant

### User Experience
- **Offline Support**: Cached data available offline
- **Loading States**: Granular loading indicators
- **Error Handling**: Comprehensive error states with recovery
- **Optimistic Updates**: Immediate UI feedback

### Developer Experience
- **Type Safety**: Full TypeScript-like safety with Dart
- **Testability**: Pure controllers easily unit tested
- **Maintainability**: Clear separation of concerns
- **Extensibility**: Easy to add new features and controllers

## 🚀 Future Enhancements

### Planned Features
1. **WebSocket Integration**: Real-time game updates
2. **Offline Sync**: Robust offline-first architecture
3. **Push Notifications**: Integration with FCM
4. **Background Refresh**: Periodic data updates
5. **Analytics**: User behavior tracking

### Performance Optimizations
1. **Lazy Loading**: Controller initialization on demand
2. **Memory Management**: Automatic cleanup of unused data
3. **Network Optimization**: Request batching and caching
4. **UI Optimization**: Virtual scrolling for large lists

## 📝 Implementation Notes

### Dependencies
- **flutter_riverpod**: State management
- **dartz**: Functional programming (Either types)
- **equatable**: Value equality (optional, can be added)

### Testing Strategy
- **Unit Tests**: Controller logic testing with mocked use cases
- **Widget Tests**: UI testing with provider overrides
- **Integration Tests**: End-to-end flow testing

### Migration Path
1. **Phase 1**: Replace existing state management with these controllers
2. **Phase 2**: Add real-time WebSocket connections
3. **Phase 3**: Implement offline-first architecture
4. **Phase 4**: Add advanced analytics and personalization

This comprehensive state management implementation provides a solid foundation for the games feature with room for growth and optimization.
