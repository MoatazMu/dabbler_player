import 'package:flutter/material.dart';
import '../models/game_creation_model.dart';
import '../services/storage_service.dart';

class GameCreationViewModel extends ChangeNotifier {
  GameCreationModel _state = GameCreationModel.initial();
  final StorageService _storageService = StorageService();

  // Available venues for demo - in real app this would come from API
  List<VenueSlot> _availableVenues = [];
  List<String> _recentTeammates = [];

  GameCreationModel get state => _state;
  List<VenueSlot> get availableVenues => List.unmodifiable(_availableVenues);
  List<String> get recentTeammates => List.unmodifiable(_recentTeammates);

  // Step navigation
  void nextStep() {
    if (_state.canProceedToNextStep && _state.nextStep != null) {
      _state = _state.copyWith(currentStep: _state.nextStep);
      
      // Load data for next step
      _loadDataForCurrentStep();
      notifyListeners();
    }
  }

  void previousStep() {
    if (_state.previousStep != null) {
      _state = _state.copyWith(currentStep: _state.previousStep);
      notifyListeners();
    }
  }

  void goToStep(GameCreationStep step) {
    _state = _state.copyWith(currentStep: step);
    _loadDataForCurrentStep();
    notifyListeners();
  }

  // Save draft functionality with step-specific state
  Future<void> saveAsDraft({Map<String, dynamic>? stepLocalState}) async {
    if (!_state.canSaveAsDraft) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final draftId = _state.draftId ?? _generateDraftId();
      final draftData = _state.copyWith(
        draftId: draftId,
        lastSaved: DateTime.now(),
        isDraft: true,
        stepLocalState: stepLocalState,
      );

      await _storageService.saveDraft(draftId, draftData.toJson());
      
      _state = draftData.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to save draft: $e',
      );
      notifyListeners();
    }
  }

  // Auto-save draft when significant changes are made
  Future<void> autoSaveDraft({Map<String, dynamic>? stepLocalState}) async {
    if (!_state.canSaveAsDraft) return;
    
    // Auto-save without showing loading state
    try {
      final draftId = _state.draftId ?? _generateDraftId();
      final draftData = _state.copyWith(
        draftId: draftId,
        lastSaved: DateTime.now(),
        isDraft: true,
        stepLocalState: stepLocalState,
      );

      await _storageService.saveDraft(draftId, draftData.toJson());
      _state = draftData;
      // Don't notify listeners for auto-save to avoid UI flicker
    } catch (e) {
      // Silently handle auto-save errors
    }
  }

  Future<List<Map<String, dynamic>>> getSavedDrafts() async {
    try {
      return await _storageService.getSavedDrafts();
    } catch (e) {
      return [];
    }
  }

  Future<void> loadDraft(String draftId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final draftData = await _storageService.loadDraft(draftId);
      if (draftData != null) {
        // Reconstruct GameFormat from saved data
        GameFormat? reconstructedFormat;
        if (draftData['selectedSport'] != null && draftData['selectedFormat'] != null) {
          reconstructedFormat = _reconstructGameFormat(
            draftData['selectedSport'], 
            draftData['selectedFormat']
          );
        }

        _state = _state.copyWith(
          // Restore current step
          currentStep: draftData['currentStep'] != null 
              ? GameCreationStep.values.firstWhere((e) => e.name == draftData['currentStep']) 
              : GameCreationStep.sportAndFormat,
          
          // Sport & Format Selection
          selectedSport: draftData['selectedSport'],
          selectedFormat: reconstructedFormat,
          skillLevel: draftData['skillLevel'],
          maxPlayers: draftData['maxPlayers'],
          gameDuration: draftData['gameDuration'],
          
          // Venue & Slot Selection
          selectedVenueSlot: draftData['selectedVenueSlot'] != null 
              ? _reconstructVenueSlot(draftData['selectedVenueSlot'])
              : null,
          amenityFilters: draftData['amenityFilters']?.cast<String>(),
          
          // Participation & Payment
          participationMode: draftData['participationMode'] != null 
              ? ParticipationMode.values.firstWhere((e) => e.name == draftData['participationMode']) 
              : null,
          paymentSplit: draftData['paymentSplit'] != null 
              ? PaymentSplit.values.firstWhere((e) => e.name == draftData['paymentSplit']) 
              : null,
          gameDescription: draftData['gameDescription'],
          allowWaitlist: draftData['allowWaitlist'],
          maxWaitlistSize: draftData['maxWaitlistSize'],
          totalCost: draftData['totalCost'],
          
          // Player Invitation
          invitedPlayerIds: draftData['invitedPlayerIds']?.cast<String>(),
          invitedPlayerEmails: draftData['invitedPlayerEmails']?.cast<String>(),
          allowFriendsToInvite: draftData['allowFriendsToInvite'],
          invitationMessage: draftData['invitationMessage'],
          
          // Review & Confirm
          gameTitle: draftData['gameTitle'],
          agreeToTerms: draftData['agreeToTerms'],
          sendReminders: draftData['sendReminders'],
          
          // Step-specific local state
          selectedDate: draftData['selectedDate'] != null 
              ? DateTime.parse(draftData['selectedDate'])
              : null,
          selectedTimeSlot: draftData['selectedTimeSlot'],
          selectedPlayers: draftData['selectedPlayers']?.cast<String>(),
          stepLocalState: draftData['stepLocalState'],
          
          // Draft metadata
          draftId: draftId,
          isDraft: true,
          lastSaved: draftData['lastSaved'] != null 
              ? DateTime.parse(draftData['lastSaved'])
              : null,
          isLoading: false,
        );
        
        // Load data for the current step
        _loadDataForCurrentStep();
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to load draft: $e',
      );
    }
    notifyListeners();
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      await _storageService.deleteDraft(draftId);
    } catch (e) {
      // Handle error silently for now
    }
  }

  String _generateDraftId() {
    return 'draft_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Step 1: Sport & Format Selection
  void selectSport(String sport) {
    _state = _state.copyWith(
      selectedSport: sport,
      selectedFormat: null, // Don't pre-select format
      maxPlayers: null,     // Reset to null until format is selected
      gameDuration: null,   // Reset to null until format is selected
    );
    notifyListeners();
    
    // Auto-save after sport selection
    autoSaveDraft();
  }

  void selectGameFormat(GameFormat format) {
    _state = _state.copyWith(
      selectedFormat: format,
      maxPlayers: format.totalPlayers,
      gameDuration: format.defaultDuration.inMinutes,
    );
    notifyListeners();
    
    // Auto-save after format selection
    autoSaveDraft();
  }

  void updateGameDuration(int durationMinutes) {
    _state = _state.copyWith(gameDuration: durationMinutes);
    notifyListeners();
    
    // Auto-save after duration update
    autoSaveDraft();
  }

  void selectSkillLevel(String skillLevel) {
    _state = _state.copyWith(skillLevel: skillLevel);
    notifyListeners();
    
    // Auto-save after skill level selection
    autoSaveDraft();
  }

  void updateMaxPlayers(int count) {
    _state = _state.copyWith(maxPlayers: count);
    notifyListeners();
  }

  // Step 2: Venue & Slot Selection
  Future<void> loadAvailableVenues() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Simulate API call - in real app, this would fetch from backend
      await Future.delayed(const Duration(seconds: 1));
      
      _availableVenues = await _generateMockVenues();
      _state = _state.copyWith(isLoading: false, error: null);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to load venues: $e',
      );
    }
    notifyListeners();
  }

  void selectVenueSlot(VenueSlot venueSlot) {
    _state = _state.copyWith(
      selectedVenueSlot: venueSlot,
      totalCost: venueSlot.timeSlot.price,
    );
    notifyListeners();
  }

  void updateVenueFilters(List<String> filters) {
    _state = _state.copyWith(venueFilters: filters);
    // Re-filter venues based on new filters
    notifyListeners();
  }

  void updateMaxDistance(double distance) {
    _state = _state.copyWith(maxDistance: distance);
    notifyListeners();
  }

  // Step 3: Participation & Payment
  void selectParticipationMode(ParticipationMode mode) {
    _state = _state.copyWith(participationMode: mode);
    notifyListeners();
  }

  void selectPaymentSplit(PaymentSplit split) {
    _state = _state.copyWith(paymentSplit: split);
    _recalculatePayments();
    notifyListeners();
  }

  void updateGameDescription(String description) {
    _state = _state.copyWith(gameDescription: description);
    notifyListeners();
  }

  void toggleWaitlist(bool allow) {
    _state = _state.copyWith(allowWaitlist: allow);
    notifyListeners();
  }

  void updateMaxWaitlistSize(int size) {
    _state = _state.copyWith(maxWaitlistSize: size);
    notifyListeners();
  }

  void updateCustomPaymentSplit(Map<String, double> split) {
    _state = _state.copyWith(customPaymentSplit: split);
    notifyListeners();
  }

  // Step 4: Player Invitation
  Future<void> loadRecentTeammates() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _recentTeammates = [
        'Ahmed Mohamed',
        'Sarah Johnson',
        'Carlos Rodriguez',
        'Fatima Al-Zahra',
        'Mike Wilson',
        'Layla Hassan',
        'David Kim',
        'Nour Abdullah',
      ];
      
      _state = _state.copyWith(isLoading: false, error: null);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to load teammates: $e',
      );
    }
    notifyListeners();
  }

  void addInvitedPlayer(String playerId) {
    final currentList = _state.invitedPlayerIds ?? [];
    if (!currentList.contains(playerId)) {
      _state = _state.copyWith(
        invitedPlayerIds: [...currentList, playerId],
      );
      notifyListeners();
    }
  }

  void removeInvitedPlayer(String playerId) {
    final currentList = _state.invitedPlayerIds ?? [];
    _state = _state.copyWith(
      invitedPlayerIds: currentList.where((id) => id != playerId).toList(),
    );
    notifyListeners();
  }

  void addInvitedEmail(String email) {
    final currentList = _state.invitedPlayerEmails ?? [];
    if (!currentList.contains(email)) {
      _state = _state.copyWith(
        invitedPlayerEmails: [...currentList, email],
      );
      notifyListeners();
    }
  }

  void removeInvitedEmail(String email) {
    final currentList = _state.invitedPlayerEmails ?? [];
    _state = _state.copyWith(
      invitedPlayerEmails: currentList.where((e) => e != email).toList(),
    );
    notifyListeners();
  }

  void updateInvitationMessage(String message) {
    _state = _state.copyWith(invitationMessage: message);
    notifyListeners();
  }

  void toggleAllowFriendsToInvite(bool allow) {
    _state = _state.copyWith(allowFriendsToInvite: allow);
    notifyListeners();
  }

  // Step 5: Review & Confirm
  void updateGameTitle(String title) {
    _state = _state.copyWith(gameTitle: title);
    notifyListeners();
  }

  void updateTermsAgreement(bool agree) {
    _state = _state.copyWith(agreeToTerms: agree);
    notifyListeners();
  }

  void updateGameReminders(bool sendReminders) {
    _state = _state.copyWith(sendReminders: sendReminders);
    notifyListeners();
  }

  void updateReminderTime(DateTime reminderTime) {
    _state = _state.copyWith(reminderTime: reminderTime);
    notifyListeners();
  }

  // Final game creation
  Future<bool> createGame() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      // Simulate API call to create game
      await Future.delayed(const Duration(seconds: 2));
      
      // In real app, this would make API call to backend
      final gameData = _state.toJson();
      print('Creating game with data: $gameData');

      // If this was a draft, delete it after successful creation
      if (_state.isDraft && _state.draftId != null) {
        await deleteDraft(_state.draftId!);
      }
      
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to create game: $e',
      );
      notifyListeners();
      return false;
    }
  }

  // Reset to initial state
  void reset() {
    _state = GameCreationModel.initial();
    _availableVenues = [];
    _recentTeammates = [];
    notifyListeners();
  }

  // Private helper methods
  void _loadDataForCurrentStep() {
    switch (_state.currentStep) {
      case GameCreationStep.venueAndSlot:
        loadAvailableVenues();
        break;
      case GameCreationStep.playerInvitation:
        loadRecentTeammates();
        break;
      default:
        break;
    }
  }

  void _recalculatePayments() {
    if (_state.selectedVenueSlot == null || _state.paymentSplit == null) return;
    
    final venueCost = _state.selectedVenueSlot!.timeSlot.price;
    final playerCount = _state.maxPlayers ?? 1;
    
    double totalCost = venueCost;
    
    switch (_state.paymentSplit!) {
      case PaymentSplit.organizer:
        totalCost = venueCost;
        break;
      case PaymentSplit.equal:
        totalCost = venueCost / playerCount;
        break;
      case PaymentSplit.perPlayer:
        totalCost = venueCost / playerCount;
        break;
      case PaymentSplit.custom:
        // Custom split would be calculated based on customPaymentSplit map
        totalCost = venueCost;
        break;
    }
    
    _state = _state.copyWith(totalCost: totalCost);
  }

  Future<List<VenueSlot>> _generateMockVenues() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return [
      VenueSlot(
        venueId: '1',
        venueName: 'Al Ahly Sports Club',
        location: 'Nasr City, Cairo',
        rating: 4.8,
        timeSlot: TimeSlot(
          startTime: tomorrow.copyWith(hour: 18, minute: 0),
          duration: const Duration(hours: 2),
          price: 200.0,
        ),
        amenities: {
          'parking': true,
          'changing_rooms': true,
          'refreshments': true,
        },
      ),
      VenueSlot(
        venueId: '2',
        venueName: 'Sporting Club',
        location: 'Alexandria',
        rating: 4.6,
        timeSlot: TimeSlot(
          startTime: tomorrow.copyWith(hour: 20, minute: 0),
          duration: const Duration(hours: 2),
          price: 180.0,
        ),
        amenities: {
          'parking': true,
          'changing_rooms': true,
        },
      ),
      VenueSlot(
        venueId: '3',
        venueName: 'New Cairo Sports Complex',
        location: 'New Cairo',
        rating: 4.9,
        timeSlot: TimeSlot(
          startTime: tomorrow.copyWith(hour: 16, minute: 0),
          duration: const Duration(hours: 2),
          price: 250.0,
        ),
        amenities: {
          'parking': true,
          'changing_rooms': true,
          'refreshments': true,
          'equipment_rental': true,
        },
      ),
    ];
  }

  // Helper method to reconstruct GameFormat from saved data
  GameFormat? _reconstructGameFormat(String sport, String formatName) {
    try {
      switch (sport.toLowerCase()) {
        case 'football':
          return FootballFormat.allFormats.firstWhere((f) => f.name == formatName);
        case 'cricket':
          return CricketFormat.allFormats.firstWhere((f) => f.name == formatName);
        case 'padel':
          return PadelFormat.allFormats.firstWhere((f) => f.name == formatName);
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Helper method to reconstruct VenueSlot from saved data
  VenueSlot? _reconstructVenueSlot(Map<String, dynamic> venueData) {
    try {
      final timeSlotData = venueData['timeSlot'];
      final timeSlot = TimeSlot(
        startTime: DateTime.parse(timeSlotData['startTime']),
        duration: Duration(minutes: timeSlotData['duration']),
        price: timeSlotData['price']?.toDouble() ?? 0.0,
        isAvailable: timeSlotData['isAvailable'] ?? true,
        restrictions: timeSlotData['restrictions']?.cast<String>() ?? [],
      );

      return VenueSlot(
        venueId: venueData['venueId'],
        venueName: venueData['venueName'],
        location: venueData['location'],
        timeSlot: timeSlot,
        amenities: venueData['amenities']?.cast<String>() ?? [],
        rating: venueData['rating']?.toDouble() ?? 0.0,
        imageUrl: venueData['imageUrl'],
      );
    } catch (e) {
      return null;
    }
  }

  // Step-specific state management for draft resume
  void updateStepLocalState(Map<String, dynamic> localState) {
    _state = _state.copyWith(stepLocalState: {
      ..._state.stepLocalState ?? {},
      ...localState,
    });
    
    // Auto-save step-specific state
    autoSaveDraft(stepLocalState: _state.stepLocalState);
  }

  void updateSelectedDate(DateTime date) {
    _state = _state.copyWith(selectedDate: date);
    notifyListeners();
    
    // Auto-save date selection
    autoSaveDraft();
  }

  void updateSelectedTimeSlot(String timeSlot) {
    _state = _state.copyWith(selectedTimeSlot: timeSlot);
    notifyListeners();
    
    // Auto-save time slot selection
    autoSaveDraft();
  }

  void updateSelectedPlayers(List<String> players) {
    _state = _state.copyWith(selectedPlayers: players);
    notifyListeners();
    
    // Auto-save player selection
    autoSaveDraft();
  }
} 