import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../../../../core/services/user_validation_service.dart';
import '../../../../utils/constants/route_constants.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.check, color: Colors.blue),
                        title: const Text('English'),
                        trailing: const Text('[Activated]', style: TextStyle(color: Colors.blue)),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Arabic'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        // App Logo
                        Image.asset(
                          'assets/logo.png',
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        const _EmailOnlyForm(),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            // Enable guest mode and go to home
                            ref.read(isGuestProvider.notifier).state = true;
                            context.go('/home');
                          },
                          child: const Text('Continue as Guest'),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextButton(
                            onPressed: () {
                              context.push('/design_system_demo');
                            },
                            child: const Text(
                              '🎨 Design System Preview',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 0,
                          children: [
                            const Text(
                              'By continuing you agree to Dabbler\'s ',
                              textAlign: TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to Terms of Use screen or open external URL
                              },
                              child: const Text(
                                'Terms of Use',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const Text(' and '),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to Privacy Policy screen or open external URL
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmailOnlyForm extends ConsumerStatefulWidget {
  const _EmailOnlyForm({super.key});

  @override
  ConsumerState<_EmailOnlyForm> createState() => _EmailOnlyFormState();
}

class _EmailOnlyFormState extends ConsumerState<_EmailOnlyForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email', errorText: state.error),
            initialValue: state.email,
            validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
            onChanged: (v) {
              _email = v;
              controller.updateEmail(v);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      final rawEmail = (_email.isNotEmpty ? _email : state.email);
                      final email = rawEmail.replaceAll(RegExp(r"[\u200B-\u200D\uFEFF]"), '').trim().toLowerCase();
                      // Show loading state
                      controller.setLoading(true);
                      try {
                        final validator = UserValidationService();
                        final exists = await validator.checkUserExists(email);
                        if (!mounted) return;
                        if (exists) {
                          context.go(RoutePaths.enterPassword, extra: email);
                        } else {
                          context.go(RoutePaths.createUserInfo, extra: email);
                        }
                      } finally {
                        if (mounted) controller.setLoading(false);
                      }
                    },
              child: state.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
