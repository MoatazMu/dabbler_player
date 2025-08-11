import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/design_system/design_tokens/spacing.dart';
import '../../../../core/config/design_system/design_tokens/typography.dart';
import '../../../../utils/constants/route_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.goNamed(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            SizedBox(height: DabblerSpacing.spacing24),
            Text(
              'Dabbler',
              style: DabblerTypography.headline1().copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
