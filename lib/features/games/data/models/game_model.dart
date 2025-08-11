import '../../domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.title,
    required super.description,
    required super.sport,
    super.venueId,
    required super.scheduledDate,
    required super.startTime,
    required super.endTime,
    required super.minPlayers,
    required super.maxPlayers,
    required super.currentPlayers,
    required super.organizerId,
    required super.skillLevel,
    required super.pricePerPlayer,
    required super.status,
    required super.isPublic,
    required super.allowsWaitlist,
    required super.checkInEnabled,
    super.cancellationDeadline,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      sport: json['sport'] as String? ?? 'football',
      venueId: json['venue_id'] as String?,
      scheduledDate: _parseDate(json['scheduled_date']),
      startTime: json['start_time'] as String? ?? '09:00',
      endTime: json['end_time'] as String? ?? '10:00',
      minPlayers: json['min_players'] as int? ?? 2,
      maxPlayers: json['max_players'] as int,
      currentPlayers: json['current_players'] as int? ?? 0,
      organizerId: json['organizer_id'] as String,
      skillLevel: json['skill_level'] as String? ?? 'beginner',
      pricePerPlayer: (json['price_per_player'] as num?)?.toDouble() ?? 0.0,
      status: _parseGameStatus(json['status']),
      isPublic: json['is_public'] as bool? ?? true,
      allowsWaitlist: json['allows_waitlist'] as bool? ?? false,
      checkInEnabled: json['check_in_enabled'] as bool? ?? false,
      cancellationDeadline: json['cancellation_deadline'] != null 
          ? DateTime.parse(json['cancellation_deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    
    if (dateData is String) {
      try {
        // Handle different date formats
        if (dateData.contains('T') || dateData.contains(' ')) {
          // Full datetime string
          return DateTime.parse(dateData);
        } else {
          // Date only string (YYYY-MM-DD)
          return DateTime.parse('${dateData}T00:00:00.000Z');
        }
      } catch (e) {
        return DateTime.now();
      }
    }

    if (dateData is DateTime) {
      return dateData;
    }

    return DateTime.now();
  }

  static GameStatus _parseGameStatus(dynamic statusData) {
    if (statusData == null) return GameStatus.upcoming;
    
    if (statusData is String) {
      try {
        return GameStatus.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == statusData.toLowerCase(),
          orElse: () => GameStatus.upcoming,
        );
      } catch (e) {
        return GameStatus.upcoming;
      }
    }

    return GameStatus.upcoming;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sport': sport,
      'venue_id': venueId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0], // Date only
      'start_time': startTime,
      'end_time': endTime,
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'current_players': currentPlayers,
      'organizer_id': organizerId,
      'skill_level': skillLevel,
      'price_per_player': pricePerPlayer,
      'status': status.toString().split('.').last,
      'is_public': isPublic,
      'allows_waitlist': allowsWaitlist,
      'check_in_enabled': checkInEnabled,
      'cancellation_deadline': cancellationDeadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    // Simplified JSON for creating new games (excludes computed fields)
    return {
      'title': title,
      'description': description,
      'sport': sport,
      if (venueId != null) 'venue_id': venueId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'organizer_id': organizerId,
      'skill_level': skillLevel,
      'price_per_player': pricePerPlayer,
      'status': status.toString().split('.').last,
      'is_public': isPublic,
      'allows_waitlist': allowsWaitlist,
      'check_in_enabled': checkInEnabled,
      if (cancellationDeadline != null) 'cancellation_deadline': cancellationDeadline!.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    // JSON for updates (excludes immutable fields like id, organizer_id, created_at)
    return {
      'title': title,
      'description': description,
      'sport': sport,
      if (venueId != null) 'venue_id': venueId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'skill_level': skillLevel,
      'price_per_player': pricePerPlayer,
      'status': status.toString().split('.').last,
      'is_public': isPublic,
      'allows_waitlist': allowsWaitlist,
      'check_in_enabled': checkInEnabled,
      if (cancellationDeadline != null) 'cancellation_deadline': cancellationDeadline!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory GameModel.fromGame(Game game) {
    return GameModel(
      id: game.id,
      title: game.title,
      description: game.description,
      sport: game.sport,
      venueId: game.venueId,
      scheduledDate: game.scheduledDate,
      startTime: game.startTime,
      endTime: game.endTime,
      minPlayers: game.minPlayers,
      maxPlayers: game.maxPlayers,
      currentPlayers: game.currentPlayers,
      organizerId: game.organizerId,
      skillLevel: game.skillLevel,
      pricePerPlayer: game.pricePerPlayer,
      status: game.status,
      isPublic: game.isPublic,
      allowsWaitlist: game.allowsWaitlist,
      checkInEnabled: game.checkInEnabled,
      cancellationDeadline: game.cancellationDeadline,
      createdAt: game.createdAt,
      updatedAt: game.updatedAt,
    );
  }

  @override
  GameModel copyWith({
    String? id,
    String? title,
    String? description,
    String? sport,
    String? venueId,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
    int? minPlayers,
    int? maxPlayers,
    int? currentPlayers,
    String? organizerId,
    String? skillLevel,
    double? pricePerPlayer,
    GameStatus? status,
    bool? isPublic,
    bool? allowsWaitlist,
    bool? checkInEnabled,
    DateTime? cancellationDeadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sport: sport ?? this.sport,
      venueId: venueId ?? this.venueId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      organizerId: organizerId ?? this.organizerId,
      skillLevel: skillLevel ?? this.skillLevel,
      pricePerPlayer: pricePerPlayer ?? this.pricePerPlayer,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      allowsWaitlist: allowsWaitlist ?? this.allowsWaitlist,
      checkInEnabled: checkInEnabled ?? this.checkInEnabled,
      cancellationDeadline: cancellationDeadline ?? this.cancellationDeadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
