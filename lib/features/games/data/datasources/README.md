# Remote Data Sources Implementation

This document outlines the comprehensive implementation of remote data sources for the games feature using Supabase as the backend.

## Overview

The implementation provides four main data sources with comprehensive error handling, real-time subscriptions, and advanced features:

1. **Games Remote Data Source** - Abstract interface with custom exceptions
2. **Supabase Games Data Source** - Complete implementation with real-time features
3. **Venues Data Source** - Location-based queries with PostGIS integration
4. **Bookings Data Source** - Transaction handling with conflict detection

## 1. Games Remote Data Source (`games_remote_data_source.dart`)

### Features
- Abstract interface defining all game-related operations
- Comprehensive custom exception hierarchy
- Support for real-time subscriptions
- Player management operations
- Location-based game discovery

### Custom Exceptions
```dart
- GameServerException - General server errors
- GameNotFoundException - Game not found
- GameFullException - Game at capacity
- InsufficientPlayersException - Not enough players
- GameAlreadyStartedException - Game already in progress
- UnauthorizedGameActionException - Permission denied
```

### Key Methods
- `createGame()` - Create new games with organizer management
- `joinGame()` - Join games with waitlist support
- `leaveGame()` - Leave games with notification handling
- `getGames()` - Fetch games with filtering and pagination
- `getGamesByLocation()` - Location-based game discovery
- Real-time streams for game updates and player events

## 2. Supabase Games Implementation (`supabase_games_datasource.dart`)

### Features
- Complete Supabase integration with 600+ lines of code
- Real-time subscriptions using StreamController
- Comprehensive game lifecycle management
- Location-based queries via RPC functions
- Advanced caching with TTL support
- Player management with waitlist handling

### Real-time Streams
```dart
Stream<List<GameModel>> get gameUpdates
Stream<PlayerEventModel> get playerEvents  
Stream<GameStatusUpdate> get gameStatusChanges
```

### Advanced Features
- **Auto-join Organizer**: Automatically adds game creator as first player
- **Waitlist Management**: Handles full games with automatic promotion
- **Location Queries**: Uses PostGIS for radius-based game discovery
- **Smart Caching**: In-memory caching with TTL for performance
- **Comprehensive Error Handling**: Specific exceptions for all error scenarios

### Database Operations
- Uses RPC functions for complex queries
- Transaction support for game state changes
- Optimistic concurrency handling
- Real-time event propagation

## 3. Venues Data Source (`venues_datasource.dart`)

### Features
- PostGIS integration for location-based queries
- Comprehensive venue management operations
- Review and rating system
- Availability checking with time slot management
- In-memory caching with TTL
- Sports configuration management

### Location-based Operations
```dart
- getNearbyVenues() - PostGIS radius queries
- searchVenuesWithLocation() - Combined text and location search
- getVenuesInBounds() - Bounding box queries
```

### Advanced Features
- **PostGIS Integration**: Uses `ST_DWithin` for precise location queries
- **Multi-sport Support**: Handles different sports configurations
- **Review System**: Comprehensive review and rating management
- **Availability Checking**: Real-time availability with booking integration
- **Smart Caching**: Venue data caching with location-aware invalidation
- **Promotion Support**: Special offers and promotional pricing

### Performance Optimizations
- Strategic caching of frequently accessed venues
- Efficient PostGIS queries for location searches
- Optimized review aggregation
- Batch operations for multiple venue updates

## 4. Bookings Data Source (`bookings_datasource.dart`)

### Features
- Transaction-based booking creation
- Comprehensive conflict detection
- Payment integration with refund support
- Booking lifecycle management
- Revenue analytics for venue owners
- Notification system for reminders

### Conflict Management
```dart
- checkBookingConflicts() - Pre-booking conflict check
- getConflictingBookings() - Detailed conflict analysis
- extendBooking() - Duration extension with conflict validation
```

### Transaction Operations
- **Atomic Booking Creation**: Uses RPC functions for transactional booking
- **Game Integration**: Updates game records with booking references
- **Payment Processing**: Integrated payment handling with refund logic
- **Cancellation Management**: Comprehensive cancellation with refund processing

### Analytics Features
- **User Statistics**: Booking history and statistics
- **Venue Revenue**: Revenue analytics for owners
- **Time Slot Analysis**: Available time slot calculations
- **No-show Tracking**: Handles booking no-shows

### Utility Methods
- Booking reminders and notifications
- Available time slot calculations  
- Revenue analytics for venue owners
- Booking history management
- No-show handling

## Error Handling Strategy

### Comprehensive Exception Hierarchy
Each data source implements specific exceptions for different error scenarios:

**Games Exceptions:**
- `GameServerException` - Database/server errors
- `GameNotFoundException` - Game doesn't exist
- `GameFullException` - Game at maximum capacity
- `InsufficientPlayersException` - Minimum players not met
- `GameAlreadyStartedException` - Game already in progress
- `UnauthorizedGameActionException` - Permission denied

**Venues Exceptions:**
- `VenueServerException` - General server errors
- `VenueNotFoundException` - Venue doesn't exist

**Bookings Exceptions:**
- `BookingServerException` - Database/server errors
- `BookingConflictException` - Time slot conflicts
- `PaymentFailedException` - Payment processing errors
- `BookingNotFoundException` - Booking doesn't exist

### Error Recovery Patterns
- Automatic retry logic for transient errors
- Graceful degradation for non-critical failures
- Detailed error messages for debugging
- Context preservation across error boundaries

## Real-time Subscriptions

### Implementation Details
All data sources support real-time updates using Supabase's real-time features:

```dart
// Games real-time updates
final gameStream = _supabaseClient
    .from('games')
    .stream(primaryKey: ['id'])
    .listen((data) => _gameController.add(data));

// Player events
final playerStream = _supabaseClient
    .from('game_players')  
    .stream(primaryKey: ['id'])
    .listen((data) => _playerController.add(data));
```

### Stream Management
- Proper stream disposal to prevent memory leaks
- Error handling within stream subscriptions
- Automatic reconnection on connection failures
- Efficient stream multiplexing for multiple clients

## Database Integration

### Supabase Features Used
- **PostgreSQL with PostGIS**: Location-based queries
- **RPC Functions**: Complex business logic on database side
- **Real-time Subscriptions**: Live data updates
- **Row Level Security**: User-based data access control
- **Triggers**: Automated data consistency checks

### Performance Optimizations
- **Connection Pooling**: Efficient database connection management
- **Query Optimization**: Strategic indexing and query patterns
- **Caching Strategies**: Multi-level caching for performance
- **Batch Operations**: Reduced database round trips

## Testing Considerations

### Unit Testing Strategy
- Mock Supabase client for isolated testing
- Test all exception scenarios
- Verify real-time subscription behavior
- Test caching mechanisms

### Integration Testing
- End-to-end data flow testing
- Real-time subscription validation
- Database transaction testing
- Error recovery verification

### Performance Testing
- Load testing for concurrent operations
- Real-time subscription scalability
- Cache effectiveness measurement
- Database query performance analysis

## Usage Examples

### Creating a Game
```dart
final gamesDataSource = SupabaseGamesDataSource(supabaseClient);

try {
  final game = await gamesDataSource.createGame(
    organizerId: 'user123',
    title: 'Evening Basketball',
    sport: 'basketball',
    maxPlayers: 10,
    location: 'Central Park Courts',
    dateTime: DateTime.now().add(Duration(days: 1)),
  );
  print('Game created: ${game.id}');
} on GameServerException catch (e) {
  print('Server error: ${e.message}');
} on GameFullException catch (e) {
  print('Game full: ${e.message}');
}
```

### Location-based Venue Search
```dart
final venuesDataSource = SupabaseVenuesDataSource(supabaseClient);

final nearbyVenues = await venuesDataSource.getNearbyVenues(
  latitude: 40.7831,
  longitude: -73.9712,
  radiusKm: 5,
  sport: 'tennis',
  limit: 20,
);

for (final venue in nearbyVenues) {
  print('${venue.name}: ${venue.distanceKm}km away');
}
```

### Booking Management
```dart
final bookingsDataSource = SupabaseBookingsDataSource(supabaseClient);

// Check for conflicts before booking
final hasConflicts = await bookingsDataSource.checkBookingConflicts(
  'venue123',
  '2024-01-15',
  '18:00',
  '20:00',
  sport: 'tennis',
);

if (!hasConflicts) {
  final booking = await bookingsDataSource.createBooking(
    'user123',
    'venue123', 
    'game456',
    '2024-01-15',
    '18:00',
    '20:00',
    sport: 'tennis',
  );
  print('Booking confirmed: ${booking.id}');
}
```

## Future Enhancements

### Planned Features
- **Offline Support**: Local caching with sync capabilities
- **Advanced Analytics**: Machine learning for game recommendations
- **Push Notifications**: Real-time mobile notifications
- **Social Features**: Friend connections and game invitations
- **Tournament Support**: Multi-game tournament management

### Performance Improvements
- **GraphQL Integration**: More efficient data fetching
- **CDN Integration**: Static asset caching
- **Database Sharding**: Horizontal scaling support
- **Caching Layers**: Redis integration for distributed caching

## Conclusion

This comprehensive remote data sources implementation provides a robust foundation for the games feature with:

- ✅ Complete CRUD operations for all entities
- ✅ Real-time subscriptions for live updates  
- ✅ Comprehensive error handling with specific exceptions
- ✅ Location-based queries with PostGIS integration
- ✅ Transaction support for data consistency
- ✅ Performance optimizations with caching
- ✅ Scalable architecture supporting future enhancements

The implementation follows clean architecture principles and provides a solid foundation for building the games feature with excellent user experience and robust data management capabilities.
