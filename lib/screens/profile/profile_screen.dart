import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            
            // Stats Section
            _buildStatsSection(context),
            const SizedBox(height: 24),
            
            // Menu Options
            _buildMenuOptions(context),
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@email.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sports Enthusiast',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to edit profile
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Games Played',
                      '47',
                      Icons.sports_soccer,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Hours Played',
                      '142',
                      Icons.access_time,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Friends',
                      '23',
                      Icons.group,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Venues Visited',
                      '12',
                      Icons.location_on,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Rating',
                      '4.8',
                      Icons.star,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Loyalty Points',
                      '850',
                      Icons.emoji_events,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildMenuCard(
            context,
            'My Activities',
            [
              _buildMenuItem(
                'My Bookings',
                Icons.book,
                () => AppRoutes.navigateToBookings(context),
              ),
              _buildMenuItem(
                'My Games',
                Icons.sports_soccer,
                () {
                  // Navigate to my games
                },
              ),
              _buildMenuItem(
                'Game History',
                Icons.history,
                () {
                  // Navigate to game history
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            'Social',
            [
              _buildMenuItem(
                'Friends',
                Icons.group,
                () {
                  // Navigate to friends
                },
              ),
              _buildMenuItem(
                'Teams',
                Icons.groups,
                () {
                  // Navigate to teams
                },
              ),
              _buildMenuItem(
                'Invitations',
                Icons.mail,
                () {
                  // Navigate to invitations
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            'Rewards',
            [
              _buildMenuItem(
                'Loyalty Points',
                Icons.emoji_events,
                () {
                  // Navigate to loyalty points
                },
              ),
              _buildMenuItem(
                'Achievements',
                Icons.star,
                () {
                  // Navigate to achievements
                },
              ),
              _buildMenuItem(
                'Referrals',
                Icons.share,
                () {
                  // Navigate to referrals
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings & Support',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                'Account Settings',
                Icons.account_circle,
                () {
                  // Navigate to account settings
                },
              ),
              _buildMenuItem(
                'Privacy & Security',
                Icons.security,
                () {
                  // Navigate to privacy settings
                },
              ),
              _buildMenuItem(
                'Notifications',
                Icons.notifications,
                () {
                  // Navigate to notification settings
                },
              ),
              _buildMenuItem(
                'Payment Methods',
                Icons.payment,
                () {
                  // Navigate to payment methods
                },
              ),
              _buildMenuItem(
                'Help & Support',
                Icons.help,
                () {
                  // Navigate to help
                },
              ),
              _buildMenuItem(
                'About',
                Icons.info,
                () {
                  // Navigate to about
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _showSignOutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle sign out logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
