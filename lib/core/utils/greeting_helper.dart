class GreetingHelper {
  /// Returns a time-based greeting message
  static String getGreeting({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

  /// Returns a time-based welcome message with additional context
  static String getWelcomeMessage({DateTime? currentTime}) {
    final greeting = getGreeting(currentTime: currentTime);
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return '$greeting Ready to start your day with some sports?';
    } else if (hour >= 12 && hour < 17) {
      return '$greeting Perfect time for a game break!';
    } else {
      return '$greeting Time to unwind with some sports!';
    }
  }

  /// Returns the time period as a string for testing purposes
  static String getTimePeriod({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }
}