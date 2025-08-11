import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../themes/design_system.dart';
import 'booking_summary_modal.dart';
import 'payment_sheet.dart';
import 'booking_success_screen.dart';

class BookingFlowScreen extends StatefulWidget {
  final Map<String, dynamic> venue;
  
  const BookingFlowScreen({
    super.key, 
    required this.venue,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedSport;
  String? selectedFormat;
  bool isLoading = false;
  bool isSlotLocked = false;
  String? lockError;
  
  // Mock available slots data
  final List<Map<String, dynamic>> _availableSlots = [
    {'time': '09:00', 'price': 120, 'available': true},
    {'time': '10:00', 'price': 120, 'available': true},
    {'time': '11:00', 'price': 120, 'available': true},
    {'time': '12:00', 'price': 150, 'available': false},
    {'time': '13:00', 'price': 150, 'available': true},
    {'time': '14:00', 'price': 150, 'available': true},
    {'time': '15:00', 'price': 150, 'available': true},
    {'time': '16:00', 'price': 180, 'available': true},
    {'time': '17:00', 'price': 180, 'available': true},
    {'time': '18:00', 'price': 200, 'available': true},
    {'time': '19:00', 'price': 200, 'available': true},
    {'time': '20:00', 'price': 200, 'available': true},
  ];

  @override
  void initState() {
    super.initState();
    // Set default sport from venue
    final sports = (widget.venue['sports'] as List<dynamic>?)?.cast<String>() ?? [];
    if (sports.isNotEmpty) {
      selectedSport = sports.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Slot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Venue Info Header
                    _buildVenueHeader(),
                    const SizedBox(height: 24),
                    
                    // Sport & Format Selection
                    _buildSportFormatSelection(),
                    const SizedBox(height: 24),
                    
                    // Date Picker
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    
                    // Time Slot Grid
                    if (selectedDate != null) _buildTimeSlotGrid(),
                    
                    const SizedBox(height: 100), // Space for sticky CTA
                  ],
                ),
              ),
            ),
            
            // Sticky Confirm & Pay Button
            if (selectedDate != null && selectedTime != null)
              _buildStickyCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueHeader() {
    final venue = widget.venue;
    final name = venue['name'] as String;
    final location = venue['location'] as String;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DS.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                  name,
                  style: DS.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: DS.caption.copyWith(
                    color: DS.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportFormatSelection() {
    final sports = (widget.venue['sports'] as List<dynamic>?)?.cast<String>() ?? [];
    final formats = (widget.venue['formats'] as List<dynamic>?)?.cast<String>() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sport & Format',
          style: DS.subtitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        
        // Sport Selection
        if (sports.length > 1) ...[
          Text(
            'Sport',
            style: DS.caption.copyWith(
              color: DS.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: sports.map((sport) {
              final isSelected = selectedSport == sport;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSport = sport;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? DS.primary : DS.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? DS.primary : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    sport,
                    style: DS.caption.copyWith(
                      color: isSelected ? Colors.white : DS.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Format Selection
        if (formats.isNotEmpty) ...[
          Text(
            'Format',
            style: DS.caption.copyWith(
              color: DS.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: formats.map((format) {
              final isSelected = selectedFormat == format;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFormat = format;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? DS.primary : DS.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? DS.primary : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    format,
                    style: DS.caption.copyWith(
                      color: isSelected ? Colors.white : DS.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePicker() {
    final today = DateTime.now();
    final dates = List.generate(14, (index) => today.add(Duration(days: index)));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: DS.subtitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = selectedDate?.day == date.day;
              final isToday = date.day == today.day;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    selectedTime = null; // Reset time when date changes
                  });
                },
                child: Container(
                  width: 60,
                  margin: EdgeInsets.only(
                    right: index < dates.length - 1 ? 12 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? DS.primary : DS.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? DS.primary : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(date.weekday),
                        style: DS.caption.copyWith(
                          color: isSelected ? Colors.white : DS.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: DS.subtitle.copyWith(
                          color: isSelected ? Colors.white : DS.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : DS.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: DS.subtitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _availableSlots.length,
          itemBuilder: (context, index) {
            final slot = _availableSlots[index];
            final time = slot['time'] as String;
            final price = slot['price'] as int;
            final available = slot['available'] as bool;
            final isSelected = selectedTime == time;
            
            return GestureDetector(
              onTap: available ? () {
                setState(() {
                  selectedTime = time;
                });
              } : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? DS.primary 
                      : available 
                          ? DS.surface 
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? DS.primary 
                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: DS.caption.copyWith(
                        color: isSelected 
                            ? Colors.white 
                            : available 
                                ? DS.onSurface 
                                : DS.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AED $price',
                      style: DS.caption.copyWith(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.8)
                            : available 
                                ? DS.onSurfaceVariant 
                                : DS.onSurfaceVariant.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStickyCTA() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DS.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lockError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: DS.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: DS.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lockError!,
                        style: DS.caption.copyWith(
                          color: DS.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleConfirmAndPay,
                style: DS.primaryButton.copyWith(
                  minimumSize: const WidgetStatePropertyAll(
                    Size.fromHeight(48),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Confirm & Pay',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Future<void> _handleConfirmAndPay() async {
    if (selectedDate == null || selectedTime == null || selectedSport == null) {
      return;
    }

    setState(() {
      isLoading = true;
      lockError = null;
    });

    try {
      // Step 1: Lock the slot
      final lockResult = await _lockSlot();
      
      if (!lockResult) {
        setState(() {
          lockError = 'Slot just taken. Please select another time.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        isSlotLocked = true;
        isLoading = false;
      });

      // Step 2: Show booking summary
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => BookingSummaryModal(
          venue: widget.venue,
          selectedDate: selectedDate!,
          selectedTime: selectedTime!,
          selectedSport: selectedSport!,
          selectedFormat: selectedFormat,
          price: _getSelectedSlotPrice(),
        ),
      );

      if (confirmed != true) {
        await _releaseSlot();
        return;
      }

      // Step 3: Show payment sheet
      final paymentResult = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PaymentSheet(
          amount: _getSelectedSlotPrice(),
          venueName: widget.venue['name'] as String,
        ),
      );

      if (paymentResult == null) {
        await _releaseSlot();
        return;
      }

      // Step 4: Confirm booking
      final bookingResult = await _confirmBooking(paymentResult);
      
      if (bookingResult) {
        // Navigate to success screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BookingSuccessScreen(
                venue: widget.venue,
                selectedDate: selectedDate!,
                selectedTime: selectedTime!,
                selectedSport: selectedSport!,
                bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
              ),
            ),
          );
        }
      } else {
        await _releaseSlot();
        setState(() {
          lockError = 'Payment failed. Please try again.';
          isLoading = false;
        });
      }

    } catch (e) {
      await _releaseSlot();
      setState(() {
        lockError = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }

  int _getSelectedSlotPrice() {
    final slot = _availableSlots.firstWhere(
      (slot) => slot['time'] == selectedTime,
      orElse: () => {'price': 150},
    );
    return slot['price'] as int;
  }

  Future<bool> _lockSlot() async {
    // Simulate API call to lock slot
    await Future.delayed(const Duration(seconds: 1));
    // Simulate 90% success rate
    return DateTime.now().millisecondsSinceEpoch % 10 != 0;
  }

  Future<void> _releaseSlot() async {
    if (isSlotLocked) {
      // Simulate API call to release slot
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        isSlotLocked = false;
      });
    }
  }

  Future<bool> _confirmBooking(Map<String, dynamic> paymentResult) async {
    // Simulate API call to confirm booking
    await Future.delayed(const Duration(seconds: 1));
    // Simulate 95% success rate
    return DateTime.now().millisecondsSinceEpoch % 20 != 0;
  }

  @override
  void dispose() {
    // Release slot if user leaves without completing booking
    if (isSlotLocked) {
      _releaseSlot();
    }
    super.dispose();
  }
} 