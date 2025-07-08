import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/game/create_game_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String explore = '/explore';
  static const String bookings = '/bookings';
  static const String createGame = '/create-game';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const BottomNavigation(),
    profile: (context) => const ProfileScreen(),
    explore: (context) => const ExploreScreen(),
    bookings: (context) => const BookingsScreen(),
    createGame: (context) => const CreateGameScreen(),
  };

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToExplore(BuildContext context) {
    Navigator.pushNamed(context, explore);
  }

  static void navigateToBookings(BuildContext context) {
    Navigator.pushNamed(context, bookings);
  }

  static void navigateToCreateGame(BuildContext context) {
    Navigator.pushNamed(context, createGame);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
