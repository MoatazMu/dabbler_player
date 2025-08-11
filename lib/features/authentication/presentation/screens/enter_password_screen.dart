import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../utils/constants/route_constants.dart';

class EnterPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const EnterPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<EnterPasswordScreen> createState() => _EnterPasswordScreenState();
}

class _EnterPasswordScreenState extends ConsumerState<EnterPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Password')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Email: ${widget.email}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        obscureText: _obscure,
                        validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                        onChanged: (v) => _password = v,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    controller.updateEmail(widget.email);
                                    controller.updatePassword(_password);
                                    await controller.login();
                                    
                                    // Check the state after login completion
                                    final currentState = ref.read(loginControllerProvider);
                                    if (currentState.session != null && currentState.error == null) {
                                      print('✅ [DEBUG] Login successful, navigating to home');
                                      if (context.mounted) {
                                        context.go('/home');
                                      }
                                    } else if (currentState.error != null) {
                                      print('❌ [DEBUG] Login failed: ${currentState.error}');
                                      // Error will be displayed by the error text widget below
                                    }
                                  }
                                },
                          child: state.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go(RoutePaths.forgotPassword, extra: {'email': widget.email}),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 8),
                        Text(state.error!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
