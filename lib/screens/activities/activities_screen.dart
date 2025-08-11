import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../themes/app_theme.dart';
import 'all_history_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshGames(BuildContext context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎮 Games refreshed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _refreshBookings(BuildContext context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📅 Bookings refreshed successfully!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      color: const Color(0xFF813FD6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activities',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your games and bookings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // IconButton(
                  //     icon: const Icon(LucideIcons.search, color: Colors.white),
                  //     onPressed: _startSearch,
                  //   ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.history, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.gamepad2, size: 20),
                      SizedBox(width: 8),
                      Text('Games'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.mapPin, size: 20),
                      SizedBox(width: 8),
                      Text('Bookings'),
                    ],
                  ),
                ),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _buildEnhancedHeader(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJoinedGamesTab(context),
                _buildBookingsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedGamesTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshGames(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Upcoming Games',
              '3 games',
              Icons.schedule,
            ),
            // const SizedBox(height: 16),
            _buildUpcomingGamesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshBookings(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Active Bookings',
              '2 venues booked',
              Icons.location_pin,
            ),
            const SizedBox(height: 16),
            _buildActiveBookingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingGamesList(BuildContext context) {
    final upcomingGames = [
      {
        'title': 'Football Match',
        'venue': 'Central Sports Complex',
        'date': 'Today',
        'time': '6:00 PM',
        'players': '9/11',
        'status': 'confirmed',
        'host': 'Alex M.',
        'sport': 'Football',
      },
      {
        'title': 'Padel Session',
        'venue': 'Elite Padel Center',
        'date': 'Tomorrow',
        'time': '7:00 PM',
        'players': '3/4',
        'status': 'confirmed',
        'host': 'Carlos R.',
        'sport': 'Padel',
      },
      {
        'title': 'Basketball Game',
        'venue': 'Downtown Court',
        'date': 'Tomorrow',
        'time': '7:30 PM',
        'players': '8/10',
        'status': 'confirmed',
        'host': 'Sarah K.',
        'sport': 'Basketball',
      },
      {
        'title': 'Tennis Doubles',
        'venue': 'Riverside Club',
        'date': 'Wed, Dec 18',
        'time': '5:00 PM',
        'players': '3/4',
        'status': 'waiting',
        'host': 'Mike R.',
        'sport': 'Tennis',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingGames.length,
      itemBuilder: (context, index) {
        final game = upcomingGames[index];
        return _buildGameCard(context, game);
      },
    );
  }



  Widget _buildGameCard(BuildContext context, Map<String, String> game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.violetCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.violetAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    game['title'] ?? '',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    game['venue'] ?? '',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${game['date'] ?? ''}, ${game['time'] ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    game['players'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingsList(BuildContext context) {
    final activeBookings = [
      {
        'venue': 'Central Sports Complex',
        'date': 'Today',
        'time': '6:00 PM - 8:00 PM',
        'sport': 'Football',
        'price': '\$50',
        'status': 'confirmed',
      },
      {
        'venue': 'Elite Padel Center',
        'date': 'Tomorrow',
        'time': '7:00 PM - 8:30 PM',
        'sport': 'Padel',
        'price': '\$60',
        'status': 'confirmed',
      },
      {
        'venue': 'Riverside Tennis Club',
        'date': 'Wed, Dec 18',
        'time': '5:00 PM - 6:30 PM',
        'sport': 'Tennis',
        'price': '\$40',
        'status': 'confirmed',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeBookings.length,
      itemBuilder: (context, index) {
        final booking = activeBookings[index];
        return _buildBookingCard(context, booking, true);
      },
    );
  }



  Widget _buildBookingCard(BuildContext context, Map<String, String> booking, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.violetCardBg, // ✅ Violet card background
        borderRadius: BorderRadius.circular(16),
        // ✅ No borders - pure violet shade design
      ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['venue']!,
                          style: context.textTheme.headlineSmall?.copyWith(  // ✅ ShadCN typography
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking['sport']!,
                          style: context.textTheme.bodySmall?.copyWith(  // ✅ ShadCN typography
                            color: context.colors.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        booking['price']!,
                        style: context.textTheme.headlineSmall?.copyWith(  // ✅ ShadCN typography
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,  // ✅ ShadCN color
                        ),
                      ),
                      _buildStatusBadge(context, booking['status']!),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(context, Icons.calendar_today, '${booking['date']} • ${booking['time']}'),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('📍 View venue details - Coming soon!'),
                              backgroundColor: context.colors.primary,  // ✅ Theme color
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showCancelDialog(context);
                        },
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🔄 Book again - Coming soon!'),
                            backgroundColor: context.colors.secondary,  // ✅ Theme color
                          ),
                        );
                      },
                      icon: Icon(Icons.refresh_outlined, color: context.colors.secondary),
                      label: const Text('Book Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.secondary,
                        side: BorderSide(color: context.colors.secondary),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor = context.successColor(true);  // ✅ Semantic success color
        textColor = context.successColor();
        displayText = 'Confirmed';
        break;
      case 'waiting':
        backgroundColor = context.warningColor(true);   // ✅ Semantic warning color
        textColor = context.warningColor();
        displayText = 'Waiting';
        break;
      case 'completed':
        backgroundColor = context.violetAccent; // ✅ Violet accent shade
        textColor = context.colors.primary;
        displayText = 'Completed';
        break;
      default:
        backgroundColor = context.violetWidgetBg; // ✅ Violet widget background
        textColor = context.colors.onSurface;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // ✅ Larger radius for modern look
        // ✅ No borders - pure violet shade design
      ),
      child: Text(
        displayText.toUpperCase(),
        style: context.textTheme.bodySmall?.copyWith(  // ✅ ShadCN typography
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.violetWidgetBg,          // ✅ Violet widget background
        borderRadius: BorderRadius.circular(8), // ✅ Slightly larger radius
        // ✅ No borders - pure violet shade design
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.primary), // ✅ Primary color for icon
          const SizedBox(width: 6),
          Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(  // ✅ ShadCN typography
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking', style: Theme.of(context).textTheme.headlineSmall),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('❌ Booking cancelled successfully'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
} 