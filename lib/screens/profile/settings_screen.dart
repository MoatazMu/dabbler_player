import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
                      onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSection(context),
            const SizedBox(height: 24),
            _buildNotificationSection(context),
            const SizedBox(height: 24),
            _buildPrivacySection(context),
            const SizedBox(height: 24),
            _buildGeneralSection(context),
            const SizedBox(height: 24),
            _buildSupportSection(context),
            const SizedBox(height: 24),
            _buildAboutSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSettingsCard(
      context,
      'Account',
      [
        _buildSettingItem(
          context,
          'Profile Information',
          'Update your personal details',
          LucideIcons.user,
          () {
            context.push('/edit_profile');
          },
        ),
        _buildSettingItem(
          context,
          'Password & Security',
          'Change password and security settings',
          LucideIcons.shield,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔐 Password & Security - Coming soon!'),
                backgroundColor: Colors.indigo,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Connected Accounts',
          'Manage social media connections',
          LucideIcons.link,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔗 Connected Accounts - Link your social media!'),
                backgroundColor: Colors.indigo,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return _buildSettingsCard(
      context,
      'Notifications',
      [
        _buildSwitchItem(
          context,
          'Push Notifications',
          'Receive notifications on your device',
          LucideIcons.bell,
          true,
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value 
                  ? '🔔 Push notifications enabled!'
                  : '🔕 Push notifications disabled!'),
                backgroundColor: value ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
        _buildSwitchItem(
          context,
          'Email Notifications',
          'Receive updates via email',
          LucideIcons.mail,
          false,
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value 
                  ? '📧 Email notifications enabled!'
                  : '📧 Email notifications disabled!'),
                backgroundColor: value ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
        _buildSwitchItem(
          context,
          'SMS Notifications',
          'Receive updates via SMS',
          LucideIcons.messageSquare,
          false,
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value 
                  ? '📱 SMS notifications enabled!'
                  : '📱 SMS notifications disabled!'),
                backgroundColor: value ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return _buildSettingsCard(
      context,
      'Privacy & Security',
      [
        _buildSwitchItem(
          context,
          'Location Services',
          'Allow app to access your location',
          LucideIcons.mapPin,
          true,
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value 
                  ? '📍 Location services enabled!'
                  : '📍 Location services disabled!'),
                backgroundColor: value ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
        _buildSwitchItem(
          context,
          'Profile Visibility',
          'Make your profile visible to others',
          LucideIcons.eye,
          true,
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value 
                  ? '👁️ Profile is now visible to others!'
                  : '👁️ Profile is now private!'),
                backgroundColor: value ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Data & Privacy',
          'Manage your data and privacy settings',
          LucideIcons.database,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🗃️ Data & Privacy settings - Coming soon!'),
                backgroundColor: Colors.purple,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return _buildSettingsCard(
      context,
      'General',
      [
        _buildSettingItem(
          context,
          'Payment Methods',
          'Manage your payment cards and methods',
          LucideIcons.creditCard,
          () {
            context.push('/payment_methods');
          },
        ),
        _buildSettingItem(
          context,
          'Language',
          'Choose your preferred language',
          LucideIcons.languages,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🌍 Language: English (Arabic coming soon!)'),
                backgroundColor: Colors.teal,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Theme & Appearance',
          'Switch between light and dark mode',
          LucideIcons.palette,
          () {
            context.push('/theme_settings');
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSettingsCard(
      context,
      'Support',
      [
        _buildSettingItem(
          context,
          'Help & Support',
          'Get help and contact support',
          LucideIcons.info,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('💬 Help & Support - FAQ available soon!'),
                backgroundColor: Colors.amber,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Report a Problem',
          'Report bugs or issues',
          LucideIcons.flag,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🚩 Report Problem - Thank you for feedback!'),
                backgroundColor: Colors.amber,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Contact Us',
          'Get in touch with our team',
          LucideIcons.mail,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📧 Contact: support@dabbler.app'),
                backgroundColor: Colors.amber,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSettingsCard(
      context,
      'About',
      [
        _buildSettingItem(
          context,
          'App Information',
          'Version, terms, and privacy policy',
          LucideIcons.info,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ℹ️ App Version: 1.0.0 Beta'),
                backgroundColor: Colors.blueGrey,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Terms of Service',
          'Read our terms and conditions',
          LucideIcons.fileText,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📄 Terms of Service - Legal document coming soon!'),
                backgroundColor: Colors.blueGrey,
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          'Privacy Policy',
          'Learn how we protect your data',
          LucideIcons.shield,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🛡️ Privacy Policy - We protect your data!'),
                backgroundColor: Colors.blueGrey,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1, height: 1),
        const SizedBox(height: 8),
        _buildSignOutItem(context),
      ],
    );
  }

  Widget _buildSignOutItem(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.red.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(LucideIcons.logOut, color: Colors.red.shade600),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(LucideIcons.chevronRight, size: 16, color: Colors.red.shade600),
        onTap: () => _showSignOutDialog(context),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to sign out?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll need to sign in again to access your account.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Signing out...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blue,
                  ),
                );
                
                try {
                  await AuthService().signOut();
                  
                  if (context.mounted) {
                    // Navigate to root (phone input screen)
                    context.go('/');
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Signed out successfully'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.error_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('Error signing out: ${e.toString()}'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
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
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        trailing: Icon(LucideIcons.chevronRight, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem(BuildContext context, String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
