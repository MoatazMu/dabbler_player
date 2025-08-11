import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../themes/design_system.dart';
import '../../routes/app_routes.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> venue;
  final DateTime selectedDate;
  final String selectedTime;
  final String selectedSport;
  final String bookingId;

  const BookingSuccessScreen({
    super.key,
    required this.venue,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedSport,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: DS.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.check,
                  size: 60,
                  color: DS.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Success Message
              Text(
                'Booking Confirmed!',
                style: DS.headline.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DS.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Your slot has been successfully booked',
                style: DS.body.copyWith(
                  color: DS.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Booking Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DS.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    // Venue Info
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: DS.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.mapPin,
                            color: DS.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venue['name'] as String,
                                style: DS.subtitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                venue['location'] as String,
                                style: DS.caption.copyWith(
                                  color: DS.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Booking Details
                    _buildDetailRow('Booking ID', bookingId),
                    _buildDetailRow('Date', _formatDate(selectedDate)),
                    _buildDetailRow('Time', selectedTime),
                    _buildDetailRow('Sport', selectedSport),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Column(
                children: [
                  // Add to Calendar Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _addToCalendar(context),
                      icon: const Icon(LucideIcons.calendar),
                      label: const Text('Add to Calendar'),
                      style: DS.primaryButton.copyWith(
                        minimumSize: const WidgetStatePropertyAll(
                          Size.fromHeight(48),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Create Game Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _createGameFromBooking(context),
                      icon: const Icon(LucideIcons.users),
                      label: const Text('Create Game from this Booking'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: DS.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // View Bookings Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _viewBookings(context),
                      icon: const Icon(LucideIcons.list),
                      label: const Text('View My Bookings'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goHome(context),
                  style: DS.primaryButton.copyWith(
                    backgroundColor: WidgetStateProperty.all(DS.surface),
                    foregroundColor: WidgetStateProperty.all(DS.onSurface),
                    minimumSize: const WidgetStatePropertyAll(
                      Size.fromHeight(48),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DS.body.copyWith(
              color: DS.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: DS.body.copyWith(
              fontWeight: FontWeight.w600,
              color: DS.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  void _addToCalendar(BuildContext context) {
    // TODO: Implement calendar integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to calendar'),
        backgroundColor: DS.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _createGameFromBooking(BuildContext context) {
    // Navigate to create game screen with pre-filled venue and slot data
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.gameCreate,
      (route) => false,
      arguments: CreateGameArguments(
        venue: venue,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        selectedSport: selectedSport,
        isFromBooking: true,
        bookingId: bookingId,
      ),
    );
  }

  void _viewBookings(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.bookings,
      (route) => false,
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }
} 