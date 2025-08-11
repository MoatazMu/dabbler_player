import 'package:flutter/material.dart';
import 'package:antd_flutter/antd_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/user_service.dart';
import '../../core/services/greeting_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/booking_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/viewmodels/explore_viewmodel.dart';
import '../../themes/app_theme.dart'; // ✅ Import for violet shade extensions
import '../../widgets/location_permission_modal.dart';
import '../../widgets/avatar_widget.dart';
import 'reminder_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final GreetingService _greetingService = GreetingService();
  final LocationService _locationService = LocationService();
  final BookingService _bookingService = BookingService();
  final StorageService _storageService = StorageService();
  final ExploreViewModel _exploreViewModel = ExploreViewModel();
  
  String _currentGreeting = '';
  bool _isLoadingGreeting = true;
  DateTime? _lastCtaTap;
  List<Map<String, dynamic>> _savedDrafts = [];
  bool _isLoadingDrafts = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initializeNotifications();
    _initializeServices();
    _loadSavedDrafts();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Refresh drafts when user returns to this screen
    _loadSavedDrafts();
  }

  Future<void> _initializeServices() async {
    await _userService.init();
    await _bookingService.init();
    _updateGreeting();
    setState(() {
      _isLoadingGreeting = false;
    });
  }

  void _updateGreeting() {
    setState(() {
      _currentGreeting = _greetingService.getGreeting();
    });
  }

  // Refresh greeting when user profile changes
  void _refreshGreeting() {
    _greetingService.clearGreetingCache();
    _updateGreeting();
  }



  // Enhanced CTA handler with debouncing and dynamic filtering
  void _handleFindGamesTap() async {
    // Debounce rapid taps (1 second)
    final now = DateTime.now();
    if (_lastCtaTap != null && now.difference(_lastCtaTap!).inSeconds < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait before searching again'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }
    _lastCtaTap = now;

    // Check location permission and handle accordingly
    if (_locationService.permissionDenied) {
      _showLocationPermissionModal();
      return;
    }

    // If location not available, try to fetch it
    if (!_locationService.hasLocation) {
      await _locationService.fetchLocation();
    }

    // Perform quick find with current user data
    final success = await _exploreViewModel.quickFind();
    
    if (success) {
      // Navigate to explore screen with pre-filled filters
      _navigateToExploreWithFilters();
    } else {
      // Handle error cases
      if (_exploreViewModel.requiresLocationPermission) {
        _showLocationPermissionModal();
      } else {
        _showSearchError();
      }
    }
  }

  void _navigateToExploreWithFilters() {
    context.push('/explore');
  }

  void _showLocationPermissionModal() {
    LocationPermissionModal.show(
      context,
      onLocationEnabled: () {
        _exploreViewModel.handleLocationPermissionResult(true);
      },
      onManualLocationSet: (area) {
        _locationService.setManualLocation(area);
        _exploreViewModel.handleLocationPermissionResult(true);
      },
    );
  }

  void _showSearchError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_exploreViewModel.getErrorMessage()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _handleFindGamesTap,
        ),
      ),
    );
  }

  Future<void> _loadSavedDrafts() async {
    setState(() {
      _isLoadingDrafts = true;
    });

    try {
      final drafts = await _storageService.getSavedDrafts();
      setState(() {
        _savedDrafts = drafts;
        _isLoadingDrafts = false;
      });
    } catch (e) {
      setState(() {
        _savedDrafts = [];
        _isLoadingDrafts = false;
      });
    }
  }

  bool get _hasSavedDrafts => _savedDrafts.isNotEmpty;



  String _getGreetingPart() {
    final greeting = _currentGreeting;
    if (greeting.isEmpty) return '';
    
    // Split by comma and take the first part
    final parts = greeting.split(',');
    return parts[0].trim();
  }

  String _getNamePart() {
    return _getUserDisplayName();
  }

  String _getUserDisplayName() {
    return _userService.getUserDisplayName();
  }

  Future<void> _handleContinueGameTap() async {
    if (_savedDrafts.isEmpty) return;

    // Get the most recent draft
    final mostRecentDraft = _savedDrafts.first;
    final draftId = mostRecentDraft['draftId'] as String;

    // Navigate to create game screen with draft ID
  context.push('/create-game', extra: {'draftId': draftId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: SvgPicture.asset(
              'assets/images/logoTypo.svg',
              height: 21,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshHomeData(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personalized Greeting with Action Icons in same row
              _buildGreetingSection(context),
              const SizedBox(height: 16),
              
              // Reminder Banner - Shows upcoming confirmed bookings
              const ReminderBanner(),
              
              // Quick Actions - Ant Design styled
              _buildQuickActions(context),
              const SizedBox(height: 16),
            
              // Upcoming Games - Ant Design styled
              _buildUpcomingGames(context),
              const SizedBox(height: 16),
            
              // Suggested Games - Ant Design styled
              _buildSuggestedGames(context),
              const SizedBox(height: 16),
            
              // Nearby Venues - Ant Design styled
              _buildNearbyVenues(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Notification Icon
        AnimatedBuilder(
          animation: _notificationService,
          builder: (context, child) {
            final unreadCount = _notificationService.unreadCount;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              // decoration: BoxDecoration(
              //   color: Theme.of(context).colorScheme.surfaceVariant,
              //   borderRadius: BorderRadius.circular(12),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       blurRadius: 4,
              //       offset: const Offset(0, 2),
              //     ),
              //   ],
              // ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.bell),
                    onPressed: () {
                      context.push('/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 2,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 21,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        // Profile Avatar
        AvatarWidget(
          name: _getUserDisplayName(),
          size: 48,
          onTap: () => context.push('/profile'),
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    return AnimatedBuilder(
      animation: _userService,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingGreeting 
                            ? 'Loading...' 
                            : _getGreetingPart(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _isLoadingGreeting 
                            ? '' 
                            : _getNamePart(),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Icons in the same row as greeting
                _buildActionIcons(context),
              ],
            ),

          ],
        );
      },
    );
  }
  // (Welcome banner removed as requested)



  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _isLoadingDrafts
                  ? _buildLoadingActionCard(context)
                  : _hasSavedDrafts
                      ? _buildContinueGameCard(context)
                      : _buildAntActionCard(
                context,
                'Create Game',
                          LucideIcons.plus,
                () => context.push('/create-game'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedFindGamesCard(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingActionCard(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.violetWidgetBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 6),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildContinueGameCard(BuildContext context) {
    final mostRecentDraft = _savedDrafts.first;
    final sport = mostRecentDraft['selectedSport'] as String?;
    final lastSaved = mostRecentDraft['lastSaved'] as String?;
    
    DateTime? lastSavedDate;
    if (lastSaved != null) {
      try {
        lastSavedDate = DateTime.parse(lastSaved);
      } catch (e) {
        // Ignore parsing error
      }
    }

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.violetWidgetBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleContinueGameTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
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
                        LucideIcons.play,
                        size: 16,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue Game',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.onSurface,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (sport != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              sport,
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.colors.primary,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (lastSavedDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 10,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatTimeAgo(lastSavedDate),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Enhanced Find Games CTA with debouncing and dynamic filtering
  Widget _buildEnhancedFindGamesCard(BuildContext context) {
    return AnimatedBuilder(
      animation: _exploreViewModel,
      builder: (context, child) {
        final isLoading = _exploreViewModel.isLoading;
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: context.violetWidgetBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _handleFindGamesTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.violetAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.colors.primary,
                                ),
                              ),
                            )
                          : Icon(
                              LucideIcons.search,
                              size: 20,
                              color: context.colors.primary,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        isLoading ? 'Searching...' : 'Find Games',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurface,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAntActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.violetWidgetBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
            padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.violetAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                icon,
                    size: 20,
                    color: context.colors.primary,
                  ),
              ),
              const SizedBox(height: 8),
                Flexible(
                  child: Text(
                title,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                      fontSize: 12,
                ),
                textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingGames(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Games',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            AntButton(
              onPressed: () => context.push('/bookings'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildAntGameCard(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAntGameCard(BuildContext context, int index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 8),
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
                    'Game ${index + 1}',
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
                    'Central Park',
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
                          'Tomorrow, 6:00 PM',
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
                        const Spacer(),
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
                    '8/10',
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

  Widget _buildSuggestedGames(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
          'Suggested for You',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
          ),
        ),
        const SizedBox(height: 12),
            ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) => _buildAntSuggestedGameCard(context, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntSuggestedGameCard(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.circle,
              size: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basketball ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Downtown Center • Today 7PM',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎮 Game details - Full details coming soon!'),
                  backgroundColor: Colors.deepPurple,
              ),
            );
          },
            icon: Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        ),
      ],
      ),
    );
  }

  Widget _buildNearbyVenues(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Venues',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            AntButton(
              onPressed: () => context.push('/explore'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
            return _buildAntVenueCard(context, index);
          },
        ),
      ],
    );
  }

  Widget _buildAntVenueCard(BuildContext context, int index) {
    final venues = [
      {'name': 'Central Sports Complex', 'distance': '0.5 km', 'type': 'Football', 'rating': '4.8'},
      {'name': 'Elite Padel Center', 'distance': '0.8 km', 'type': 'Padel', 'rating': '4.9'},
      {'name': 'Downtown Fitness Center', 'distance': '1.2 km', 'type': 'Basketball', 'rating': '4.6'},
      {'name': 'Riverside Recreation', 'distance': '2.1 km', 'type': 'Tennis', 'rating': '4.9'},
    ];

    final venue = venues[index];
    
              return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.mapPin,
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
                  venue['name']!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                      children: [
                        Icon(
                      LucideIcons.navigation,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      venue['distance']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        venue['type']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.star,
                    size: 12,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 2),
                        Text(
                    venue['rating']!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3), 
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'Available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
          ),
        ),
      ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshHomeData(BuildContext context) async {
    // Refresh all services
    await Future.wait([
      _bookingService.refresh(),
      _loadSavedDrafts(),
      Future.delayed(const Duration(seconds: 1)), // Simulate other data refresh
    ]);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🏠 Dashboard refreshed successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
