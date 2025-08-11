import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/avatar_widget.dart';
import '../../core/services/user_service.dart';

// Ant Design Button Helper
enum AntdButtonType { primary, defaultType, ghost }
enum AntdButtonSize { small, medium, large }

class AntdButton extends StatelessWidget {
  final AntdButtonType type;
  final AntdButtonSize size;
  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;

  const AntdButton({
    super.key,
    required this.type,
    required this.onPressed,
    required this.child,
    this.size = AntdButtonSize.medium,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = () {
      switch (size) {
        case AntdButtonSize.small:
          return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
        case AntdButtonSize.large:
          return const EdgeInsets.symmetric(vertical: 18, horizontal: 32);
        case AntdButtonSize.medium:
          return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
      }
    }();
    final minWidth = fullWidth ? double.infinity : null;
    switch (type) {
      case AntdButtonType.primary:
        return SizedBox(
          width: minWidth,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: child,
          ),
        );
      case AntdButtonType.defaultType:
        return SizedBox(
          width: minWidth,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: child,
          ),
        );
      case AntdButtonType.ghost:
        return SizedBox(
          width: minWidth,
          child: IconButton(
            onPressed: onPressed,
            icon: child,
            padding: padding,
            constraints: const BoxConstraints(),
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        );
    }
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final currentUser = _userService.currentUser;
      if (currentUser != null) {
        // Display name is stored as firstName in our model
        _firstNameController.text = currentUser.displayName;
        _lastNameController.text = ''; // We don't use lastName separately
        _emailController.text = currentUser.email ?? '';
        _phoneController.text = currentUser.phone ?? '';
        _bioController.text = currentUser.bio ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: AntdButton(
          type: AntdButtonType.ghost,
          size: AntdButtonSize.small,
          onPressed: () => AppRoutes.goBack(context),
          child: Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePhotoSection(context),
              const SizedBox(height: 32),
              _buildPersonalInfoSection(context),
              const SizedBox(height: 24),
              _buildContactInfoSection(context),
              const SizedBox(height: 24),
              _buildBioSection(context),
              const SizedBox(height: 32),
              _buildSaveButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context) {
    final currentUser = _userService.currentUser;
    final userName = currentUser?.displayName ?? 'Player';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              children: [
                AvatarWidget(
                  name: userName,
                  size: 80,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  textColor: Theme.of(context).colorScheme.primary,
                ),
                // Positioned(
                //   bottom: 0,
                //   right: 0,
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Theme.of(context).colorScheme.secondary,
                //       shape: BoxShape.circle,
                //       border: Border.all(color: Colors.white, width: 2),
                //     ),
                //     child: AntdButton(
                //       type: AntdButtonType.ghost,
                //       size: AntdButtonSize.small,
                //       onPressed: () {
                //         // Handle photo upload
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(content: Text('Photo upload feature coming soon!')),
                //         );
                //       },
                //       child: Icon(
                //         LucideIcons.camera,
                //         size: 16,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Profile Photo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // const SizedBox(height: 8),
            // Text(
            //   'Tap the camera icon to update your photo',
            //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //         color: Colors.grey[600],
            //       ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Display Name',
              controller: _firstNameController,
              prefixIcon: LucideIcons.user,
              hintText: 'Enter your display name',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Phone Number',
              controller: _phoneController,
              prefixIcon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Bio',
              controller: _bioController,
              prefixIcon: LucideIcons.type,
              maxLines: 4,
              hintText: 'Tell others about yourself and your sports interests...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Save Changes',
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              await _userService.updateUserFields(
                displayName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
                email: _emailController.text.isEmpty ? null : _emailController.text,
                phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                bio: _bioController.text.isEmpty ? null : _bioController.text,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              AppRoutes.goBack(context);
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update profile: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        variant: ButtonVariant.primary,
        size: ButtonSize.large,
        icon: LucideIcons.save,
      ),
    );
  }
}
