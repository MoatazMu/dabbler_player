import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/booking_service.dart';
import '../../core/models/booking_model.dart';
import '../../themes/app_theme.dart';

class ReminderBanner extends StatefulWidget {
  const ReminderBanner({super.key});

  @override
  State<ReminderBanner> createState() => _ReminderBannerState();
}

class _ReminderBannerState extends State<ReminderBanner> {
  final BookingService _bookingService = BookingService();
  Timer? _countdownTimer;
  Duration? _currentCountdown;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (mounted) {
      setState(() {
        _currentCountdown = _bookingService.getCountdownToNext();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bookingService,
      builder: (context, child) {
        if (!_bookingService.hasActiveReminders) {
          return const SizedBox.shrink();
        }

        final nextBooking = _bookingService.nextBooking;
        if (nextBooking == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Dismissible(
            key: Key('reminder_${nextBooking.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _bookingService.dismissBooking(nextBooking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reminder dismissed'),
                  backgroundColor: context.colors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    LucideIcons.x,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            child: _buildReminderCard(context, nextBooking),
          ),
        );
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, BookingModel booking) {
    final countdown = _currentCountdown;
    final isUrgent = _bookingService.isBookingSoon(booking);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUrgent 
            ? [
                Colors.orange.withValues(alpha: 0.1),
                Colors.red.withValues(alpha: 0.05),
              ]
            : [
                context.colors.primary.withValues(alpha: 0.1),
                context.colors.secondary.withValues(alpha: 0.05),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent 
            ? Colors.orange.withValues(alpha: 0.3)
            : context.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/bookings'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and dismiss hint
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUrgent 
                          ? Colors.orange.withValues(alpha: 0.2)
                          : context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isUrgent ? LucideIcons.clock : LucideIcons.calendar,
                        size: 18,
                        color: isUrgent ? Colors.orange : context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isUrgent ? 'Starting Soon!' : 'Upcoming Game',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isUrgent ? Colors.orange : context.colors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronLeft,
                      size: 16,
                      color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Game details
                Text(
                  booking.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.venue,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Countdown and time info
                Row(
                  children: [
                    // Countdown
                    if (countdown != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUrgent 
                            ? Colors.orange.withValues(alpha: 0.2)
                            : context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.timer,
                              size: 14,
                              color: isUrgent ? Colors.orange : context.colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _bookingService.formatCountdown(countdown),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isUrgent ? Colors.orange : context.colors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Game time
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatGameTime(booking.dateTime),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Sport badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.violetAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.sport,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action hint
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 14,
                      color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tap to view details • Swipe left to dismiss',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatGameTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final gameDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (gameDate == today) {
      dateStr = 'Today';
    } else if (gameDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = _getWeekday(dateTime.weekday);
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
