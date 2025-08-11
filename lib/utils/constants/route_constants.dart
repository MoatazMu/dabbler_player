/// Route paths used throughout the app
class RoutePaths {
  // Core Routes
  static const String splash = '/';
  static const String home = '/home';
  static const String error = '/error';
  
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String enterPassword = '/enter-password';
  static const String createUserInfo = '/create_user_information';
  static const String setPassword = '/set_password';
  static const String welcome = '/welcome';
  static const String resetPassword = '/reset-password';
  
  // Feature Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  
  // Games Routes
  static const String games = '/games';
  static const String availableGames = '/games/available';
  static const String myGames = '/games/my-games';
  static const String gameHistory = '/games/history';
  static const String gameDetail = '/games/:gameId';
  static const String joinGame = '/games/:gameId/join';
  static const String gameCheckin = '/games/:gameId/checkin';
  static const String gameLobby = '/games/:gameId/lobby';
  static const String liveGame = '/games/:gameId/live';
  static const String postGame = '/games/:gameId/post-game';
  
  // Game Creation Routes
  static const String createGame = '/create-game';
  static const String createGameBasicInfo = '/create-game/basic-info';
  static const String createGameVenueSelection = '/create-game/venue-selection';
  static const String createGameDateTime = '/create-game/date-time';
  static const String createGamePlayerSettings = '/create-game/player-settings';
  static const String createGamePricing = '/create-game/pricing';
  static const String createGameAdditionalDetails = '/create-game/additional-details';
  static const String createGameReview = '/create-game/review';
  
  // Venue Routes
  static const String venuesList = '/venues';
  static const String venueDetail = '/venues/:venueId';
  
  // Deep Link Routes
  static const String deepLinkPrefix = 'dabbler://app';
}

/// Route names for semantic navigation
class RouteNames {
  // Core Routes
  static const String splash = 'splash';
  static const String home = 'home';
  static const String error = 'error';
  
  // Auth Routes
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot_password';
  static const String enterPassword = 'enter_password';
  static const String createUserInfo = 'create_user_information';
  static const String setPassword = 'set_password';
  static const String welcome = 'welcome';
  static const String resetPassword = 'reset_password';
  
  // Feature Routes
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  
  // Games Routes
  static const String games = 'games';
  static const String availableGames = 'available-games';
  static const String myGames = 'my-games';
  static const String gameHistory = 'game-history';
  static const String gameDetail = 'game-detail';
  static const String joinGame = 'join-game';
  static const String gameCheckin = 'game-checkin';
  static const String gameLobby = 'game-lobby';
  static const String liveGame = 'live-game';
  static const String postGame = 'post-game';
  
  // Game Creation Routes
  static const String createGame = 'create-game';
  static const String createGameBasicInfo = 'create-game-basic-info';
  static const String createGameVenueSelection = 'create-game-venue-selection';
  static const String createGameDateTime = 'create-game-date-time';
  static const String createGamePlayerSettings = 'create-game-player-settings';
  static const String createGamePricing = 'create-game-pricing';
  static const String createGameAdditionalDetails = 'create-game-additional-details';
  static const String createGameReview = 'create-game-review';
  
  // Venue Routes
  static const String venuesList = 'venues-list';
  static const String venueDetail = 'venue-detail';
}

/// Route parameters used in dynamic routes
class RouteParams {
  static const String errorMessage = 'errorMessage';
  static const String gameId = 'gameId';
  static const String venueId = 'venueId';
  static const String playerId = 'playerId';
  static const String inviteToken = 'inviteToken';
  static const String userId = 'userId';
  static const String itemId = 'itemId';
}
