import 'package:flutter/material.dart';
import '../core/components/dabbler_button.dart';
import '../core/components/dabbler_card.dart';
import '../core/components/dabbler_form_field.dart';
import '../core/config/design_system/design_tokens/spacing.dart';
import '../core/config/design_system/design_tokens/typography.dart';

/// A demo screen showcasing the new design system components
class DesignSystemDemo extends StatelessWidget {
  const DesignSystemDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Design System Demo',
          style: DabblerTypography.headline6(),
        ),
      ),
      body: SingleChildScrollView(
        padding: DabblerSpacing.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buttons',
              style: DabblerTypography.headline5(),
            ),
            SizedBox(height: DabblerSpacing.spacing16),
            Wrap(
              spacing: DabblerSpacing.spacing8,
              runSpacing: DabblerSpacing.spacing8,
              children: [
                DabblerButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  variant: ButtonVariant.primary,
                ),
                DabblerButton(
                  text: 'Secondary Button',
                  onPressed: () {},
                  variant: ButtonVariant.secondary,
                ),
                DabblerButton(
                  text: 'Text Button',
                  onPressed: () {},
                  variant: ButtonVariant.text,
                ),
                DabblerButton(
                  text: 'Loading',
                  onPressed: () {},
                  isLoading: true,
                ),
                DabblerButton(
                  text: 'Disabled',
                  onPressed: null,
                ),
              ],
            ),
            SizedBox(height: DabblerSpacing.spacing32),
            Text(
              'Cards',
              style: DabblerTypography.headline5(),
            ),
            SizedBox(height: DabblerSpacing.spacing16),
            DabblerContentCard(
              title: 'Content Card',
              subtitle: 'With title, subtitle, content and actions',
              content: const Text(
                'This is an example of a content card with multiple elements. '
                'It demonstrates the spacing, typography, and component composition.',
              ),
              actions: [
                DabblerButton(
                  text: 'Cancel',
                  onPressed: () {},
                  variant: ButtonVariant.text,
                ),
                SizedBox(width: DabblerSpacing.spacing8),
                DabblerButton(
                  text: 'Submit',
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: DabblerSpacing.spacing32),
            Text(
              'Form Fields',
              style: DabblerTypography.headline5(),
            ),
            SizedBox(height: DabblerSpacing.spacing16),
            DabblerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DabblerFormField(
                    label: 'Username',
                    placeholder: 'Enter your username',
                    helperText: 'This will be your display name',
                  ),
                  SizedBox(height: DabblerSpacing.spacing16),
                  const DabblerFormField(
                    label: 'Password',
                    placeholder: '••••••••',
                    obscureText: true,
                  ),
                  SizedBox(height: DabblerSpacing.spacing16),
                  DabblerFormField(
                    label: 'Email',
                    placeholder: 'Enter your email',
                    errorText: 'Please enter a valid email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
