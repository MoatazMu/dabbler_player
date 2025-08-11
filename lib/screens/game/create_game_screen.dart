import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/game_creation_model.dart';
import '../../core/viewmodels/game_creation_viewmodel.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'steps/sport_format_step.dart';
import 'steps/venue_slot_step.dart';
import 'steps/participation_payment_step.dart';
import 'steps/player_invitation_step.dart';
import 'steps/review_confirmation_step.dart';

class CreateGameScreen extends StatefulWidget {
  final String? draftId;
  
  const CreateGameScreen({super.key, this.draftId});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  late final GameCreationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GameCreationViewModel();
    if (widget.draftId != null) {
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    try {
      await _viewModel.loadDraft(widget.draftId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Failed to load draft: $e',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
    return Scaffold(
          backgroundColor: context.colors.surface,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(context),
              
              // Step content
              Expanded(
                child: _buildStepContent(context),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(context),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Game',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          Text(
            _viewModel.state.stepTitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.close, color: context.colors.onSurfaceVariant),
        tooltip: 'Cancel',
        onPressed: () => _handleCancelPressed(context),
        splashRadius: 24,
      ),
      actions: [
        if (_viewModel.state.currentStep != GameCreationStep.sportAndFormat)
          SizedBox(
            height: kToolbarHeight,
            width: 80,
            child: TextButton(
              onPressed: () => _viewModel.reset(),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.primary,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(80, kToolbarHeight),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Reset'),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final progress = _viewModel.state.progress;
    final stepIndex = _viewModel.state.stepIndex;
    final totalSteps = _viewModel.state.totalSteps;
    final canSaveAsDraft = _viewModel.state.canSaveAsDraft;
    final isLoading = _viewModel.state.isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with step info and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${stepIndex + 1} of $totalSteps',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _viewModel.state.stepTitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (canSaveAsDraft) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: isLoading ? null : () => _handleSaveAsDraft(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.save,
                              size: 14,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Save Draft',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar with step indicators
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Active progress
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.primary,
                        context.colors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < stepIndex;
                  final isCurrent = index == stepIndex;
                  
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? context.colors.primary
                          : context.colors.outline.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.surface,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(
                            LucideIcons.check,
                            size: 6,
                            color: context.colors.onPrimary,
                          )
                        : null,
                  );
                }),
              ),
            ],
          ),
          
          // Last saved indicator (if draft exists)
          if (_viewModel.state.isDraft && _viewModel.state.lastSaved != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 12,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last saved ${_getTimeAgo(_viewModel.state.lastSaved!)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleSaveAsDraft(BuildContext context) async {
    try {
      await _viewModel.saveAsDraft();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Draft saved successfully',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Failed to save draft: $e',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_viewModel.state.currentStep) {
      case GameCreationStep.sportAndFormat:
        return SportFormatStep(viewModel: _viewModel);
      case GameCreationStep.venueAndSlot:
        return VenueSlotStep(viewModel: _viewModel);
      case GameCreationStep.participationAndPayment:
        return ParticipationPaymentStep(viewModel: _viewModel);
      case GameCreationStep.playerInvitation:
        return PlayerInvitationStep(viewModel: _viewModel);
      case GameCreationStep.reviewAndConfirm:
        return ReviewConfirmationStep(viewModel: _viewModel);
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final state = _viewModel.state;
    final canGoBack = state.previousStep != null;
    final canGoNext = state.canProceedToNextStep;
    final isLastStep = state.currentStep == GameCreationStep.reviewAndConfirm;
    final isLoading = state.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (canGoBack)
            Expanded(
              child: CustomButton(
                text: 'Back',
                onPressed: isLoading ? null : () => _viewModel.previousStep(),
                variant: ButtonVariant.secondary,
                icon: LucideIcons.arrowLeft,
              ),
            ),
          
          if (canGoBack) const SizedBox(width: 12),
          
          // Next/Create button
          Expanded(
            flex: canGoBack ? 1 : 2,
            child: CustomButton(
              text: isLastStep ? 'Create Game' : 'Continue',
              onPressed: canGoNext && !isLoading ? _handleNextPressed : null,
              variant: ButtonVariant.primary,
              icon: isLastStep ? null : LucideIcons.arrowRight,
              loading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackPressed(BuildContext context) {
    final state = _viewModel.state;
    
    if (state.previousStep != null) {
      _viewModel.previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleNextPressed() async {
    final state = _viewModel.state;
    
    if (state.currentStep == GameCreationStep.reviewAndConfirm) {
      // Final step - create the game
      final success = await _viewModel.createGame();
      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted && _viewModel.state.error != null) {
        _showErrorDialog(_viewModel.state.error!);
      }
    } else {
      // Continue to next step
      _viewModel.nextStep();
    }
  }

  void _handleCancelPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.xCircle,
                color: context.colors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Cancel Game Creation',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel game creation? You will lose all unsaved progress.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        actions: [
          CustomButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.secondary,
          ),
          CustomButton(
            text: 'Confirm Cancel',
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close create game screen
            },
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.check,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Game Created!',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Your game has been created successfully. Players will be notified about the invitation.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        actions: [
          CustomButton(
            text: 'Done',
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close create game screen
            },
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.alertCircle,
                color: context.colors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Error',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          error,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        actions: [
          CustomButton(
            text: 'Try Again',
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
