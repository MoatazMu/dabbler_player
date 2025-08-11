# Game Operations Use Cases Implementation

This document outlines the comprehensive implementation of use cases for game operations in the Dabbler app. Each use case follows Clean Architecture principles and implements robust validation, error handling, and business logic.

## Overview

The implementation provides seven comprehensive use cases covering the complete game lifecycle:

1. **CreateGameUseCase** - Game creation with venue booking
2. **JoinGameUseCase** - Player joining with waitlist support  
3. **FindGamesUseCase** - Game discovery with location filtering
4. **BookVenueUseCase** - Venue booking with payment processing
5. **CheckInGameUseCase** - Player check-in with multiple methods
6. **CancelGameUseCase** - Game cancellation with notifications
7. **RatePlayersUseCase** - Post-game player rating system

## Architecture Pattern

All use cases extend the base `UseCase<T, Params>` class and follow the pattern:

```dart
class SomeUseCase extends UseCase<Either<Failure, Result>, SomeParams> {
  @override
  Future<Either<Failure, Result>> call(SomeParams params) async {
    // 1. Parameter validation
    // 2. Business logic validation  
    // 3. Repository operations
    // 4. Side effects (notifications, etc.)
    // 5. Return result
  }
}
```

## 1. CreateGameUseCase

### Purpose
Creates new games with comprehensive validation, venue availability checking, and automatic organizer enrollment.

### Key Features
- **Parameter Validation**: Validates game title, sport, player limits, dates, times, and pricing
- **Time Logic**: Ensures game is scheduled in future with proper start/end time logic
- **Venue Integration**: Checks venue availability using BookingsRepository
- **Auto-join**: Automatically enrolls game creator as first player
- **Initial Booking**: Creates venue booking if venue is specified

### Usage Example
```dart
final useCase = CreateGameUseCase(
  gamesRepository: gamesRepository,
  venuesRepository: venuesRepository, 
  bookingsRepository: bookingsRepository,
);

final result = await useCase(CreateGameParams(
  title: 'Evening Basketball',
  sport: 'basketball',
  scheduledDate: DateTime.now().add(Duration(days: 1)),
  startTime: '18:00',
  endTime: '20:00',
  minPlayers: 6,
  maxPlayers: 10,
  organizerId: 'user123',
  skillLevel: 'intermediate',
  pricePerPlayer: 15.0,
  venueId: 'venue456',
));
```

### Validations
- Title and sport cannot be empty
- Player limits must be logical (min ≤ max, both > 0)
- Date must be in future
- Times must be valid 24-hour format
- End time must be after start time
- Duration must be 30 minutes to 8 hours
- Price cannot be negative
- Skill level must be valid option
- Venue availability (if specified)

## 2. JoinGameUseCase

### Purpose
Handles player joining games with comprehensive eligibility checking, waitlist management, and notification system.

### Key Features
- **Eligibility Validation**: Checks if player can join specific game
- **Duplicate Prevention**: Prevents joining same game twice
- **Timing Restrictions**: Prevents joining games starting within 15 minutes
- **Waitlist Support**: Automatically handles full games with waitlist
- **Notifications**: Sends appropriate notifications to players and organizers
- **Position Tracking**: Provides waitlist position information

### Usage Example
```dart
final result = await joinGameUseCase(JoinGameParams(
  gameId: 'game123',
  playerId: 'player456',
));

result.fold(
  (failure) => print('Join failed: ${failure.message}'),
  (success) => print(success.message),
);
```

### Business Rules
- Cannot join own games as organizer
- Cannot join games starting within 15 minutes
- Cannot join non-public games
- Cannot join completed/cancelled games
- Automatic waitlist placement if game is full

## 3. FindGamesUseCase

### Purpose
Discovers games based on location, date, sport, and other filters with distance calculations and intelligent filtering.

### Key Features
- **Location-based Search**: Uses Haversine formula for distance calculations
- **Comprehensive Filtering**: Date range, sport, skill level, price range
- **Smart Exclusions**: Excludes user's own games and unjoinable games
- **Distance Sorting**: Automatically sorts by distance when location provided
- **Waitlist Options**: Option to include/exclude games with waitlists
- **Pagination Support**: Efficient pagination for large result sets

### Usage Example
```dart
final result = await findGamesUseCase(FindGamesParams(
  userLatitude: 40.7831,
  userLongitude: -73.9712,
  radiusKm: 10.0,
  sport: 'tennis',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 7)),
  skillLevel: 'intermediate',
  maxPricePerPlayer: 25.0,
  excludeUserId: 'currentUser123',
  page: 1,
  limit: 20,
));
```

### Advanced Features
- **Distance Calculation**: Precise distance using Earth's curvature
- **Intelligent Filtering**: Excludes unjoinable games automatically
- **Performance Optimized**: Efficient database queries with proper indexing
- **Flexible Search**: Multiple filter combinations supported

## 4. BookVenueUseCase

### Purpose
Handles venue booking with availability checking, dynamic pricing, and payment processing.

### Key Features
- **Availability Checking**: Verifies no conflicting bookings
- **Operating Hours**: Validates booking within venue hours
- **Dynamic Pricing**: Peak hours, weekend, and court-specific rates
- **Payment Integration**: Stub for payment processor integration
- **Transaction Safety**: Cancels booking if payment fails
- **Cost Calculation**: Comprehensive cost breakdown with taxes and fees

### Usage Example
```dart
final result = await bookVenueUseCase(BookVenueParams(
  userId: 'user123',
  venueId: 'venue456',
  date: DateTime.now().add(Duration(days: 1)),
  startTime: '18:00',
  endTime: '20:00',
  durationMinutes: 120,
  sport: 'tennis',
  courtNumber: 'Court 1',
));
```

### Pricing Logic
- **Base Rate**: Venue's hourly rate × duration
- **Peak Hours**: 50% surcharge for 6-9 AM and 5-10 PM
- **Weekend Rate**: 25% surcharge for Saturday/Sunday
- **Taxes & Fees**: 10% tax + $2 service fee
- **Court-specific**: Support for different court rates (when available)

## 5. CheckInGameUseCase

### Purpose
Manages player check-in with multiple verification methods and game readiness tracking.

### Key Features
- **Multiple Methods**: QR code, manual, and location-based check-in
- **Time Window**: 30-minute check-in window before game start
- **Security**: QR code validation with expiration and tampering protection
- **Authority Check**: Manual check-in requires organizer authorization
- **Location Verification**: GPS-based check-in for venue proximity
- **Game Readiness**: Tracks minimum player requirements

### Usage Examples

#### QR Code Check-in
```dart
final result = await checkInUseCase(CheckInGameParams(
  gameId: 'game123',
  playerId: 'player456',
  method: CheckInMethod.qrCode,
  qrCodeData: 'DABBLER_CHECKIN:game123:1641234567890:hash123',
));
```

#### Manual Check-in
```dart
final result = await checkInUseCase(CheckInGameParams(
  gameId: 'game123',
  playerId: 'player456',
  method: CheckInMethod.manual,
  checkedInBy: 'organizer789',
));
```

#### Location-based Check-in
```dart
final result = await checkInUseCase(CheckInGameParams(
  gameId: 'game123',
  playerId: 'player456',
  method: CheckInMethod.location,
  playerLatitude: 40.7831,
  playerLongitude: -73.9712,
));
```

### Security Features
- **QR Code Validation**: Format verification and expiration checking
- **Authority Verification**: Only organizers can perform manual check-in
- **Location Proximity**: GPS verification for location-based check-in
- **Tampering Protection**: Hash verification for QR codes (stub)

## 6. CancelGameUseCase

### Purpose
Handles game cancellation with player notifications, booking cancellations, and refund processing.

### Key Features
- **Authorization Check**: Only organizers can cancel games
- **Deadline Enforcement**: Respects cancellation deadlines
- **Booking Integration**: Automatically cancels associated venue bookings
- **Notification System**: Notifies all affected players
- **Refund Processing**: Handles refunds for cancelled bookings
- **Multi-channel Notifications**: Email, push, and in-app notifications

### Usage Example
```dart
final result = await cancelGameUseCase(CancelGameParams(
  gameId: 'game123',
  userId: 'organizer456',
  reason: 'Venue double-booked, unable to secure alternative location',
  processRefunds: true,
  notifyPlayers: true,
));
```

### Business Rules
- **Authorization**: Only game organizer can cancel
- **Timing**: Cannot cancel after deadline (default: 2 hours before start)
- **Status Check**: Cannot cancel completed or in-progress games
- **Reason Required**: Must provide cancellation reason (minimum 10 characters)

### Notification Flow
1. **Player Notifications**: Individual notifications to all registered players
2. **Organizer Updates**: Confirmation to game organizer
3. **Email Notifications**: Follow-up emails with details
4. **External Systems**: Calendar and social media updates (stub)

## 7. RatePlayersUseCase

### Purpose
Post-game player rating system with comprehensive validation and statistics tracking.

### Key Features
- **Game Completion**: Only allows rating after game completion
- **Participation Verification**: Verifies rater participated in game  
- **Multi-dimensional Ratings**: Overall, skill, sportsmanship, punctuality
- **Comment System**: Optional comments with length limits
- **Duplicate Prevention**: Prevents multiple ratings of same player
- **Statistics Updates**: Updates player profiles with new ratings

### Usage Example
```dart
final result = await ratePlayersUseCase(RatePlayersParams(
  gameId: 'game123',
  raterId: 'player456',
  ratings: [
    PlayerRating(
      playerId: 'player789',
      overallRating: 4,
      skillRating: 4,
      sportsmanshipRating: 5,
      punctualityRating: 4,
      comment: 'Great player, very fair and skilled!',
    ),
    PlayerRating(
      playerId: 'player101',
      overallRating: 3,
      skillRating: 3,
      sportsmanshipRating: 4,
      punctualityRating: 2,
      comment: 'Good player but arrived late',
    ),
  ],
));
```

### Rating Validation
- **Range Checking**: All ratings must be 1-5 stars
- **Self-rating Prevention**: Cannot rate yourself  
- **Duplicate Prevention**: Cannot rate same player twice
- **Participation Verification**: Must have participated in game
- **Comment Limits**: Maximum 500 characters
- **Game Status**: Game must be completed

### Statistics Impact
- **Player Profiles**: Updates average ratings and total games rated
- **Skill Tracking**: Maintains separate averages for different rating types
- **Reputation System**: Contributes to overall player reputation scores
- **Feedback Loop**: Helps improve matching and game quality

## Error Handling Strategy

### Consistent Error Pattern
All use cases use consistent error handling with specific failure types:

```dart
// Game-specific failures
class GameFailure extends Failure {
  const GameFailure(super.message);
}

// Specific failure types
class VenueUnavailableFailure extends GameFailure { ... }
class InvalidGameParametersFailure extends GameFailure { ... }
```

### Error Categories
1. **Validation Errors**: Invalid parameters or business rule violations
2. **Authorization Errors**: Insufficient permissions for operations
3. **Timing Errors**: Operations outside allowed time windows
4. **Resource Errors**: Unavailable venues, full games, etc.
5. **System Errors**: Database failures, network issues, etc.

## Testing Strategy

### Unit Testing
Each use case includes comprehensive unit tests covering:

```dart
group('CreateGameUseCase', () {
  test('should create game successfully with valid parameters', () { ... });
  test('should fail when title is empty', () { ... });
  test('should fail when venue is unavailable', () { ... });
  test('should auto-join organizer after creation', () { ... });
});
```

### Test Categories
- **Happy Path**: Successful execution with valid data
- **Validation Tests**: All parameter validation scenarios
- **Business Logic**: Complex business rule validation
- **Error Handling**: Proper error propagation and messages
- **Side Effects**: Verification of notifications, updates, etc.

## Integration Points

### Repository Dependencies
- **GamesRepository**: Core game CRUD operations
- **VenuesRepository**: Venue data and availability
- **BookingsRepository**: Venue booking management
- **NotificationService**: Player and organizer notifications (future)
- **PaymentService**: Payment processing integration (future)

### External Services
- **Payment Processors**: Stripe, PayPal, etc. (stubbed)
- **Notification Services**: Push notifications, email, SMS (stubbed)
- **Location Services**: GPS validation and distance calculations
- **Calendar Integration**: External calendar updates (stubbed)

## Performance Considerations

### Database Optimization
- **Efficient Queries**: Proper indexing on frequently queried fields
- **Pagination**: Limit result sets for large data operations
- **Caching**: Strategic caching of frequently accessed data
- **Connection Pooling**: Efficient database connection management

### Scalability Features
- **Async Operations**: All use cases are fully asynchronous
- **Batch Processing**: Efficient handling of multiple operations
- **Resource Management**: Proper cleanup of resources
- **Error Recovery**: Graceful handling of failures

## Future Enhancements

### Planned Features
1. **Advanced Notifications**: Rich push notifications with actions
2. **Payment Integration**: Full payment processor integration
3. **Social Features**: Friend invitations and social sharing
4. **AI Matching**: Intelligent game and player matching
5. **Tournament Support**: Multi-game tournament management

### Scalability Improvements
1. **Event Sourcing**: Audit trail for all game operations
2. **CQRS Pattern**: Separate read/write operations for better performance
3. **Microservices**: Split into smaller, focused services
4. **Real-time Updates**: WebSocket integration for live updates

## Conclusion

This comprehensive use case implementation provides a robust foundation for game operations with:

- ✅ **Complete Game Lifecycle**: Creation, joining, discovery, check-in, cancellation, and rating
- ✅ **Robust Validation**: Comprehensive parameter and business rule validation
- ✅ **Error Handling**: Consistent error patterns with specific failure types
- ✅ **Business Logic**: Complex rules for timing, authorization, and resource management
- ✅ **Integration Ready**: Proper interfaces for external services
- ✅ **Performance Optimized**: Efficient queries and resource management
- ✅ **Extensible Architecture**: Easy to add new features and capabilities

The implementation follows clean architecture principles and provides excellent maintainability, testability, and scalability for the Dabbler gaming platform.
