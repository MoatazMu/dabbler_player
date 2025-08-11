import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../domain/entities/game.dart';
import '../../domain/usecases/cancel_game_usecase.dart';

enum MyGameType {
  upcoming,
  past,
  organized,
  joined,
}

enum QuickAction {
  share,
  cancel,
  checkIn,
  viewDetails,
  invite,
  rate,
}

class GameStatistics {
  final int totalGamesPlayed;
  final int totalGamesOrganized;
  final int gamesThisMonth;
  final double averageRating;
  final String favoritesSport;
  final Duration totalPlayTime;
  final int cancelledGames;
  final double attendanceRate;

  const GameStatistics({
    required this.totalGamesPlayed,
    required this.totalGamesOrganized,
    required this.gamesThisMonth,
    required this.averageRating,
    required this.favoritesSport,
    required this.totalPlayTime,
    required this.cancelledGames,
    required this.attendanceRate,
  });

  GameStatistics copyWith({
    int? totalGamesPlayed,
    int? totalGamesOrganized,
    int? gamesThisMonth,
    double? averageRating,
    String? favoritesSport,
    Duration? totalPlayTime,
    int? cancelledGames,
    double? attendanceRate,
  }) {
    return GameStatistics(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalGamesOrganized: totalGamesOrganized ?? this.totalGamesOrganized,
      gamesThisMonth: gamesThisMonth ?? this.gamesThisMonth,
      averageRating: averageRating ?? this.averageRating,
      favoritesSport: favoritesSport ?? this.favoritesSport,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      cancelledGames: cancelledGames ?? this.cancelledGames,
      attendanceRate: attendanceRate ?? this.attendanceRate,
    );
  }
}

class CheckInReminder {
  final String gameId;
  final String gameTitle;
  final DateTime scheduledTime;
  final String venue;
  final bool isActive;

  const CheckInReminder({
    required this.gameId,
    required this.gameTitle,
    required this.scheduledTime,
    required this.venue,
    this.isActive = true,
  });

  Duration get timeUntilGame => scheduledTime.difference(DateTime.now());
  bool get isUpcoming => timeUntilGame.inMinutes > 0;
  bool get shouldShowReminder => timeUntilGame.inHours <= 2 && timeUntilGame.inMinutes > 0;
}

class MyGamesState {
  final List<Game> upcomingGames;
  final List<Game> pastGames;
  final List<Game> organizedGames;
  final List<Game> joinedGames;
  final bool isLoadingUpcoming;
  final bool isLoadingPast;
  final bool isLoadingOrganized;
  final bool isLoadingJoined;
  final bool isLoadingStatistics;
  final String? error;
  final GameStatistics? statistics;
  final List<CheckInReminder> checkInReminders;
  final DateTime? lastUpdated;
  final Timer? reminderTimer;

  const MyGamesState({
    this.upcomingGames = const [],
    this.pastGames = const [],
    this.organizedGames = const [],
    this.joinedGames = const [],
    this.isLoadingUpcoming = false,
    this.isLoadingPast = false,
    this.isLoadingOrganized = false,
    this.isLoadingJoined = false,
    this.isLoadingStatistics = false,
    this.error,
    this.statistics,
    this.checkInReminders = const [],
    this.lastUpdated,
    this.reminderTimer,
  });

  bool get isLoading => isLoadingUpcoming || isLoadingPast || isLoadingOrganized || isLoadingJoined;
  bool get hasError => error != null;
  bool get hasUpcomingGames => upcomingGames.isNotEmpty;
  bool get hasPastGames => pastGames.isNotEmpty;
  bool get hasStatistics => statistics != null;
  bool get hasActiveReminders => checkInReminders.any((r) => r.isActive && r.shouldShowReminder);

  int get totalGames => upcomingGames.length + pastGames.length;
  
  List<Game> get todayGames {
    final today = DateTime.now();
    return upcomingGames.where((game) => 
      game.scheduledDate.year == today.year &&
      game.scheduledDate.month == today.month &&
      game.scheduledDate.day == today.day
    ).toList();
  }

  List<Game> get thisWeekGames {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    return upcomingGames.where((game) => 
      game.scheduledDate.isAfter(weekStart) && game.scheduledDate.isBefore(weekEnd)
    ).toList();
  }

  MyGamesState copyWith({
    List<Game>? upcomingGames,
    List<Game>? pastGames,
    List<Game>? organizedGames,
    List<Game>? joinedGames,
    bool? isLoadingUpcoming,
    bool? isLoadingPast,
    bool? isLoadingOrganized,
    bool? isLoadingJoined,
    bool? isLoadingStatistics,
    String? error,
    GameStatistics? statistics,
    List<CheckInReminder>? checkInReminders,
    DateTime? lastUpdated,
    Timer? reminderTimer,
  }) {
    return MyGamesState(
      upcomingGames: upcomingGames ?? this.upcomingGames,
      pastGames: pastGames ?? this.pastGames,
      organizedGames: organizedGames ?? this.organizedGames,
      joinedGames: joinedGames ?? this.joinedGames,
      isLoadingUpcoming: isLoadingUpcoming ?? this.isLoadingUpcoming,
      isLoadingPast: isLoadingPast ?? this.isLoadingPast,
      isLoadingOrganized: isLoadingOrganized ?? this.isLoadingOrganized,
      isLoadingJoined: isLoadingJoined ?? this.isLoadingJoined,
      isLoadingStatistics: isLoadingStatistics ?? this.isLoadingStatistics,
      error: error,
      statistics: statistics ?? this.statistics,
      checkInReminders: checkInReminders ?? this.checkInReminders,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      reminderTimer: reminderTimer ?? this.reminderTimer,
    );
  }
}

class MyGamesController extends StateNotifier<MyGamesState> {
  final CancelGameUseCase _cancelGameUseCase;
  final String userId;
  
  // TODO: Add other use cases when available
  // final GetUserGamesUseCase _getUserGamesUseCase;
  // final GetGameStatisticsUseCase _getGameStatisticsUseCase;
  // final CheckInGameUseCase _checkInGameUseCase;
  // final ShareGameUseCase _shareGameUseCase;

  static const Duration _cacheValidity = Duration(minutes: 5);
  static const Duration _reminderCheckInterval = Duration(minutes: 1);

  MyGamesController({
    required CancelGameUseCase cancelGameUseCase,
    required this.userId,
  })  : _cancelGameUseCase = cancelGameUseCase,
        super(const MyGamesState()) {
    _initializeMyGames();
    _startReminderTimer();
  }

  /// Initialize and load all user games
  Future<void> _initializeMyGames() async {
    await Future.wait([
      loadUpcomingGames(),
      loadPastGames(),
      loadGameStatistics(),
    ]);
  }

  /// Load upcoming games for user
  Future<void> loadUpcomingGames() async {
    if (!_shouldRefresh()) return;
    
    state = state.copyWith(isLoadingUpcoming: true, error: null);
    
    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(seconds: 1));
      
      final mockUpcomingGames = _generateMockUpcomingGames();
      
      state = state.copyWith(
        upcomingGames: mockUpcomingGames,
        isLoadingUpcoming: false,
        lastUpdated: DateTime.now(),
      );
      
      // Update check-in reminders
      _updateCheckInReminders();
      
    } catch (e) {
      state = state.copyWith(
        isLoadingUpcoming: false,
        error: 'Failed to load upcoming games: $e',
      );
    }
  }

  /// Load past games for user
  Future<void> loadPastGames() async {
    state = state.copyWith(isLoadingPast: true, error: null);
    
    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockPastGames = _generateMockPastGames();
      
      state = state.copyWith(
        pastGames: mockPastGames,
        isLoadingPast: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoadingPast: false,
        error: 'Failed to load past games: $e',
      );
    }
  }

  /// Load organized games
  Future<void> loadOrganizedGames() async {
    state = state.copyWith(isLoadingOrganized: true, error: null);
    
    try {
      final organizedGames = [
        ...state.upcomingGames.where((g) => g.organizerId == userId),
        ...state.pastGames.where((g) => g.organizerId == userId),
      ];
      
      state = state.copyWith(
        organizedGames: organizedGames,
        isLoadingOrganized: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoadingOrganized: false,
        error: 'Failed to load organized games: $e',
      );
    }
  }

  /// Load joined games (not organized by user)
  Future<void> loadJoinedGames() async {
    state = state.copyWith(isLoadingJoined: true, error: null);
    
    try {
      final joinedGames = [
        ...state.upcomingGames.where((g) => g.organizerId != userId),
        ...state.pastGames.where((g) => g.organizerId != userId),
      ];
      
      state = state.copyWith(
        joinedGames: joinedGames,
        isLoadingJoined: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoadingJoined: false,
        error: 'Failed to load joined games: $e',
      );
    }
  }

  /// Load game statistics
  Future<void> loadGameStatistics() async {
    state = state.copyWith(isLoadingStatistics: true);
    
    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final mockStatistics = GameStatistics(
        totalGamesPlayed: 45,
        totalGamesOrganized: 18,
        gamesThisMonth: 6,
        averageRating: 4.3,
        favoritesSport: 'basketball',
        totalPlayTime: const Duration(hours: 120),
        cancelledGames: 3,
        attendanceRate: 0.92,
      );
      
      state = state.copyWith(
        statistics: mockStatistics,
        isLoadingStatistics: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoadingStatistics: false,
        error: 'Failed to load statistics: $e',
      );
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = state.copyWith(lastUpdated: null); // Force refresh
    await _initializeMyGames();
  }

  /// Cancel a game (organizer only)
  Future<void> cancelGame(String gameId, String reason) async {
    try {
      final result = await _cancelGameUseCase(CancelGameParams(
        gameId: gameId,
        userId: userId,
        reason: reason,
        processRefunds: true,
        notifyPlayers: true,
      ));
      
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (success) {
          // Remove cancelled game from upcoming games
          final updatedUpcoming = state.upcomingGames
              .where((game) => game.id != gameId)
              .toList();
          
          state = state.copyWith(
            upcomingGames: updatedUpcoming,
            error: null,
          );
          
          // Update organized games
          loadOrganizedGames();
        },
      );
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel game: $e');
    }
  }

  /// Share game details
  Future<String> shareGame(String gameId) async {
    try {
      final game = _findGameById(gameId);
      if (game == null) {
        throw Exception('Game not found');
      }
      
      // TODO: Implement ShareGameUseCase
      final shareText = _generateShareText(game);
      
      // For now, just return the share text
      return shareText;
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to share game: $e');
      return '';
    }
  }

  /// Check in to a game
  Future<void> checkInToGame(String gameId) async {
    try {
      // TODO: Implement CheckInGameUseCase integration
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update game status or refresh data
      await loadUpcomingGames();
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to check in: $e');
    }
  }

  /// Get available quick actions for a game
  List<QuickAction> getAvailableActions(Game game) {
    final actions = <QuickAction>[];
    
    // Always available
    actions.add(QuickAction.viewDetails);
    actions.add(QuickAction.share);
    
    final now = DateTime.now();
    final gameDateTime = _combineDateTime(game.scheduledDate, game.startTime);
    final timeUntilGame = gameDateTime.difference(now);
    
    if (game.status == GameStatus.upcoming) {
      // Game is upcoming
      if (game.organizerId == userId) {
        // User is organizer
        if (timeUntilGame.inHours > 2) {
          actions.add(QuickAction.cancel);
        }
        actions.add(QuickAction.invite);
      }
      
      // Check-in available 30 minutes before game
      if (timeUntilGame.inMinutes <= 30 && timeUntilGame.inMinutes > -15) {
        actions.add(QuickAction.checkIn);
      }
    } else if (game.status == GameStatus.completed) {
      // Game is completed
      actions.add(QuickAction.rate);
    }
    
    return actions;
  }

  /// Execute quick action
  Future<void> executeQuickAction(QuickAction action, String gameId) async {
    switch (action) {
      case QuickAction.share:
        await shareGame(gameId);
        break;
      case QuickAction.cancel:
        // This would typically show a confirmation dialog
        // For now, we'll just call cancel with a default reason
        await cancelGame(gameId, 'Game cancelled by organizer');
        break;
      case QuickAction.checkIn:
        await checkInToGame(gameId);
        break;
      case QuickAction.viewDetails:
        // This would navigate to game details
        // Implementation depends on navigation system
        break;
      case QuickAction.invite:
        // This would show invite UI
        // Implementation depends on UI system
        break;
      case QuickAction.rate:
        // This would show rating UI
        // Implementation depends on UI system
        break;
    }
  }

  /// Private helper methods

  bool _shouldRefresh() {
    if (state.lastUpdated == null) return true;
    return DateTime.now().difference(state.lastUpdated!) > _cacheValidity;
  }

  void _startReminderTimer() {
    final timer = Timer.periodic(_reminderCheckInterval, (timer) {
      if (mounted) {
        _updateCheckInReminders();
      } else {
        timer.cancel();
      }
    });
    
    state = state.copyWith(reminderTimer: timer);
  }

  void _updateCheckInReminders() {
    final now = DateTime.now();
    final reminders = <CheckInReminder>[];
    
    for (final game in state.upcomingGames) {
      final gameDateTime = _combineDateTime(game.scheduledDate, game.startTime);
      final timeUntilGame = gameDateTime.difference(now);
      
      // Create reminder for games starting within 2 hours
      if (timeUntilGame.inMinutes > 0 && timeUntilGame.inHours <= 2) {
        reminders.add(CheckInReminder(
          gameId: game.id,
          gameTitle: game.title,
          scheduledTime: gameDateTime,
          venue: game.venueId ?? 'TBD',
          isActive: true,
        ));
      }
    }
    
    state = state.copyWith(checkInReminders: reminders);
  }

  DateTime _combineDateTime(DateTime date, String time) {
    final timeParts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  Game? _findGameById(String gameId) {
    // Search in all game lists
    for (final game in [...state.upcomingGames, ...state.pastGames]) {
      if (game.id == gameId) return game;
    }
    return null;
  }

  String _generateShareText(Game game) {
    final buffer = StringBuffer();
    buffer.writeln('🏀 ${game.title}');
    buffer.writeln('🗓️ ${_formatDate(game.scheduledDate)}');
    buffer.writeln('🕐 ${game.startTime} - ${game.endTime}');
    buffer.writeln('👥 ${game.currentPlayers}/${game.maxPlayers} players');
    
    if (game.pricePerPlayer > 0) {
      buffer.writeln('💰 \$${game.pricePerPlayer.toStringAsFixed(2)} per player');
    }
    
    buffer.writeln('\nJoin us on Dabbler! 🎯');
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  List<Game> _generateMockUpcomingGames() {
    final now = DateTime.now();
    
    return [
      Game(
        id: 'game1',
        title: 'Evening Basketball',
        description: 'Competitive basketball game',
        sport: 'basketball',
        scheduledDate: now.add(const Duration(days: 1)),
        startTime: '18:00',
        endTime: '20:00',
        minPlayers: 6,
        maxPlayers: 10,
        currentPlayers: 8,
        organizerId: userId, // User is organizer
        skillLevel: 'intermediate',
        pricePerPlayer: 15.0,
        status: GameStatus.upcoming,
        isPublic: true,
        allowsWaitlist: true,
        checkInEnabled: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
        venueId: 'venue1',
      ),
      Game(
        id: 'game2',
        title: 'Tennis Practice',
        description: 'Casual tennis practice session',
        sport: 'tennis',
        scheduledDate: now.add(const Duration(days: 3)),
        startTime: '10:00',
        endTime: '12:00',
        minPlayers: 2,
        maxPlayers: 4,
        currentPlayers: 3,
        organizerId: 'other_user',
        skillLevel: 'beginner',
        pricePerPlayer: 25.0,
        status: GameStatus.upcoming,
        isPublic: true,
        allowsWaitlist: false,
        checkInEnabled: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        venueId: 'venue2',
      ),
      Game(
        id: 'game3',
        title: 'Weekend Soccer',
        description: 'Fun weekend soccer match',
        sport: 'soccer',
        scheduledDate: now.add(const Duration(days: 5)),
        startTime: '15:00',
        endTime: '17:00',
        minPlayers: 14,
        maxPlayers: 22,
        currentPlayers: 18,
        organizerId: userId, // User is organizer
        skillLevel: 'mixed',
        pricePerPlayer: 0.0, // Free game
        status: GameStatus.upcoming,
        isPublic: true,
        allowsWaitlist: true,
        checkInEnabled: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
    ];
  }

  List<Game> _generateMockPastGames() {
    final now = DateTime.now();
    
    return [
      Game(
        id: 'past_game1',
        title: 'Morning Basketball',
        description: 'Great morning game',
        sport: 'basketball',
        scheduledDate: now.subtract(const Duration(days: 2)),
        startTime: '08:00',
        endTime: '10:00',
        minPlayers: 6,
        maxPlayers: 10,
        currentPlayers: 9,
        organizerId: 'other_user',
        skillLevel: 'intermediate',
        pricePerPlayer: 20.0,
        status: GameStatus.completed,
        isPublic: true,
        allowsWaitlist: true,
        checkInEnabled: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
        venueId: 'venue1',
      ),
      Game(
        id: 'past_game2',
        title: 'Volleyball Match',
        description: 'Competitive volleyball',
        sport: 'volleyball',
        scheduledDate: now.subtract(const Duration(days: 7)),
        startTime: '19:00',
        endTime: '21:00',
        minPlayers: 8,
        maxPlayers: 12,
        currentPlayers: 12,
        organizerId: userId, // User organized this
        skillLevel: 'advanced',
        pricePerPlayer: 18.0,
        status: GameStatus.completed,
        isPublic: true,
        allowsWaitlist: false,
        checkInEnabled: true,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 7)),
        venueId: 'venue3',
      ),
    ];
  }

  @override
  void dispose() {
    state.reminderTimer?.cancel();
    super.dispose();
  }
}
