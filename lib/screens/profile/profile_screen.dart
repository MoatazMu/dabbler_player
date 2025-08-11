import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../activities/activities_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../core/services/auth_service.dart';
import '../../widgets/avatar_widget.dart';

String capitalize(String text) {
  if (text.isEmpty) return text;
  return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  late final StreamSubscription<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _authStream = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _user = Supabase.instance.client.auth.currentUser;
      });
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = AuthService();
      final user = authService.getCurrentUser();
      final profile = await authService.getUserProfile();
      
      if (mounted) {
        setState(() {
          _user = user;
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(LucideIcons.settings, size: 20),
              onPressed: () {
                context.push('/settings');
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(context),
                    const SizedBox(height: 32),
                    // Stats Section
                    _buildStatsSection(context),
                    const SizedBox(height: 32),
                    // Menu Options
                    _buildMenuOptions(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final userName = _userProfile?['name'] ?? 'User';
    final userEmail = _user?.email ?? 'No email';
    final userPhone = _userProfile?['phone'] ?? _user?.phone;
    final userAge = _userProfile?['age'];
    final userGender = _userProfile?['gender'];
    final userSports = _userProfile?['sports'] as List<dynamic>?;
    final userIntent = _userProfile?['intent'];

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              // Avatar and edit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: AvatarWidget(
                        name: userName,
                        size: 72,
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        textColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),                  IconButton(
                    icon: Icon(
                      LucideIcons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Edit Profile',
                    onPressed: () {
                      context.push('/edit_profile');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // User Name
              Align(
                alignment: Alignment.center,
                child: Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // User Email
              Text(
                userEmail,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              // User Phone (if available)
              if (userPhone != null) ...[
                const SizedBox(height: 4),
                Text(
                  userPhone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              
              // User Details (Age, Gender)
              if (userAge != null || userGender != null) ...[
                const SizedBox(height: 8),
                Text(
                  [
                    if (userAge != null) '$userAge years old',
                    if (userGender != null) capitalize(userGender),
                  ].join(' • '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Sports and Intent Chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Sports Chip
                  if (userSports != null && userSports.isNotEmpty)
                    Chip(
                      label: Text(
                        '${userSports.length} Sports',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  
                  // Intent Chip
                  if (userIntent != null)
                    Chip(
                      label: Text(
                        capitalize(userIntent),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: [
            _buildStatItem(context, 'Games', '47', LucideIcons.gamepad2),
            _buildStatItem(context, 'Hours', '142', LucideIcons.clock),
            _buildStatItem(context, 'Friends', '23', LucideIcons.users),
            _buildStatItem(context, 'Venues', '12', LucideIcons.mapPin),
            _buildStatItem(context, 'Rating', '4.8', LucideIcons.star),
            _buildStatItem(context, 'Points', '850', LucideIcons.trophy),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        // no border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        _buildMenuCard(
          context,
          'My Activities',
          [
            _buildMenuItem(
              'My Bookings',
              LucideIcons.book,
              () => context.push('/bookings'),
            ),
            _buildMenuItem(
              'My Games',
              LucideIcons.gamepad2,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('My Games - Coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            _buildMenuItem(
              'Game History',
              LucideIcons.history,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ActivitiesScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1, height: 1),
        const SizedBox(height: 8),
        _buildMenuCard(
          context,
          'Social',
          [
            _buildMenuItem(
              'Friends',
              LucideIcons.users,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Friends - Feature under development!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            _buildMenuItem(
              'Teams',
              LucideIcons.users,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teams - Feature under development!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            _buildMenuItem(
              'Invitations',
              LucideIcons.mail,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invitations - Feature under development!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1, height: 1),
        const SizedBox(height: 8),
        _buildMenuCard(
          context,
          'Rewards',
          [
            _buildMenuItem(
              'Loyalty Points',
              LucideIcons.trophy,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🏆 Loyalty Points: 850 points available!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            _buildMenuItem(
              'Achievements',
              LucideIcons.star,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⭐ Achievements: 12 unlocked, 8 remaining!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            _buildMenuItem(
              'Referrals',
              LucideIcons.share,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔗 Referrals: Invite friends and earn rewards!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _refreshProfileData(BuildContext context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👤 Profile data refreshed successfully!'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

