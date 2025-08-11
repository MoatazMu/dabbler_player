import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../utils/constants/route_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _sent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    final prefill = extra is Map && extra['email'] is String ? extra['email'] as String : (extra is String ? extra : null);
    if (prefill != null && _emailController.text.isEmpty) {
      _emailController.text = prefill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _submit(context),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _submit(context),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Send Reset Link'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_sent)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'If an account exists for this email, a reset link was sent. Check your inbox and spam folder.',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.login),
                      child: const Text('Back to login'),
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

  void _submit(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService().sendPasswordResetEmail(email);
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
