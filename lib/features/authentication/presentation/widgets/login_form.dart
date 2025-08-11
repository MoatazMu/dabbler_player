import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../../../utils/validators/email_validator.dart';
import '../../../../utils/validators/password_validator.dart';
import '../../../../utils/mixins/validation_mixin.dart';
import 'password_strength_indicator.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            initialValue: state.email,
            validator: (v) => EmailValidator().validate(v ?? ''),
            onChanged: (v) {
              _email = v;
              controller.updateEmail(v);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            obscureText: _obscure,
            initialValue: state.password,
            validator: (v) => PasswordValidator().validate(v ?? ''),
            onChanged: (v) {
              _password = v;
              controller.updatePassword(v);
            },
          ),
          PasswordStrengthIndicator(password: _password),
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Text(state.error!, style: TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await controller.login();
                        // Navigation handled in parent
                      }
                    },
              child: state.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
