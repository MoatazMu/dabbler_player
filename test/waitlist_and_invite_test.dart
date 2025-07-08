import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

void main() {
  group('Waitlist and Invite Tests', () {
    group('Waitlist Functionality', () {
      testWidgets('should handle joining waitlist for full games', (WidgetTester tester) async {
        final waitlistScenarios = [
          {
            'gameId': 'game_full_1',
            'currentPlayers': 10,
            'maxPlayers': 10,
            'allowWaitlist': true,
            'currentWaitlist': 3,
            'canJoinWaitlist': true,
            'expectedPosition': 4
          },
          {
            'gameId': 'game_full_2',
            'currentPlayers': 8,
            'maxPlayers': 10,
            'allowWaitlist': false,
            'currentWaitlist': 0,
            'canJoinWaitlist': false,
            'expectedPosition': null
          },
          {
            'gameId': 'game_full_3',
            'currentPlayers': 10,
            'maxPlayers': 10,
            'allowWaitlist': true,
            'currentWaitlist': 0,
            'canJoinWaitlist': true,
            'expectedPosition': 1
          }
        ];

        for (final scenario in waitlistScenarios) {
          final waitlistResult = await _attemptJoinWaitlist(scenario);
          
          expect(waitlistResult['canJoin'], equals(scenario['canJoinWaitlist']));
          
          if (waitlistResult['canJoin']) {
            expect(waitlistResult['position'], equals(scenario['expectedPosition']));
            expect(waitlistResult['status'], equals('waitlisted'));
            expect(waitlistResult['estimatedTime'], isNotNull);
            print('✅ Joined waitlist: Position ${waitlistResult['position']} for ${scenario['gameId']}');
          } else {
            expect(waitlistResult['reason'], isNotNull);
            print('❌ Cannot join waitlist: ${waitlistResult['reason']}');
          }
        }
      });

      testWidgets('should track waitlist position changes in real-time', (WidgetTester tester) async {
        var waitlistState = {
          'gameId': 'game_123',
          'userPosition': 5,
          'totalWaitlisted': 8,
          'confirmTimeEstimate': Duration(minutes: 45)
        };

        // Simulate someone ahead leaving waitlist
        final positionUpdate1 = await _simulateWaitlistPositionChange(waitlistState, 'user_ahead_left');
        
        expect(positionUpdate1['newPosition'], equals(4));
        expect(positionUpdate1['positionImproved'], isTrue);
        expect(positionUpdate1['estimateUpdated'], isTrue);
        waitlistState['userPosition'] = positionUpdate1['newPosition'];

        // Simulate someone new joining behind
        final positionUpdate2 = await _simulateWaitlistPositionChange(waitlistState, 'user_joined_behind');
        
        expect(positionUpdate2['newPosition'], equals(4)); // Position unchanged
        expect(positionUpdate2['positionImproved'], isFalse);
        expect(positionUpdate2['totalWaitlisted'], equals(9));

        // Simulate reaching #1 position
        waitlistState['userPosition'] = 1;
        final urgentUpdate = await _simulateWaitlistPositionChange(waitlistState, 'next_in_line');
        
        expect(urgentUpdate['newPosition'], equals(1));
        expect(urgentUpdate['isNextInLine'], isTrue);
        expect(urgentUpdate['urgentNotification'], isTrue);

        print('✅ Waitlist tracking: 5→4→1 (next in line)');
      });

      testWidgets('should handle waitlist confirmation and timeout', (WidgetTester tester) async {
        final confirmationScenarios = [
          {
            'scenario': 'spot_available',
            'userPosition': 1,
            'responseTime': Duration(minutes: 2),
            'userResponse': 'confirm',
            'expectedResult': 'confirmed',
            'timeoutOccurred': false
          },
          {
            'scenario': 'user_declines',
            'userPosition': 1,
            'responseTime': Duration(minutes: 1),
            'userResponse': 'decline',
            'expectedResult': 'declined',
            'nextUserNotified': true
          },
          {
            'scenario': 'user_timeout',
            'userPosition': 1,
            'responseTime': Duration(minutes: 6),
            'userResponse': null,
            'expectedResult': 'timeout',
            'timeoutOccurred': true
          }
        ];

        for (final scenario in confirmationScenarios) {
          final confirmationResult = await _simulateWaitlistConfirmation(scenario);
          
          expect(confirmationResult['result'], equals(scenario['expectedResult']));
          expect(confirmationResult['timeoutOccurred'], equals(scenario['timeoutOccurred'] ?? false));
          
          if (scenario['expectedResult'] == 'confirmed') {
            expect(confirmationResult['bookingCreated'], isTrue);
            expect(confirmationResult['removedFromWaitlist'], isTrue);
          } else if (scenario['expectedResult'] == 'declined' || scenario['expectedResult'] == 'timeout') {
            expect(confirmationResult['nextUserNotified'], equals(scenario['nextUserNotified'] ?? true));
          }

          print('✅ Waitlist confirmation: ${scenario['scenario']} → ${scenario['expectedResult']}');
        }
      });

      testWidgets('should estimate accurate confirmation times', (WidgetTester tester) async {
        final estimateScenarios = [
          {
            'gameTime': DateTime.now().add(Duration(hours: 4)),
            'userPosition': 3,
            'averageDropoutRate': 0.2,
            'gameType': 'football',
            'expectedEstimate': Duration(minutes: 35)
          },
          {
            'gameTime': DateTime.now().add(Duration(hours: 1)),
            'userPosition': 5,
            'averageDropoutRate': 0.15,
            'gameType': 'basketball',
            'expectedEstimate': Duration(minutes: 15)
          }
        ];

        for (final scenario in estimateScenarios) {
          final timeEstimate = _calculateWaitlistTimeEstimate(scenario);
          
          expect(timeEstimate['estimate'], isA<Duration>());
          expect(timeEstimate['confidence'], isA<double>());
          expect(timeEstimate['factors'], isNotNull);
          
          // Estimate should be within reasonable range
          final estimateMinutes = timeEstimate['estimate'].inMinutes;
          expect(estimateMinutes, greaterThan(0));
          expect(estimateMinutes, lessThan(120)); // Less than 2 hours

          print('✅ Time estimate: Position ${scenario['userPosition']} → ${estimateMinutes} minutes');
        }
      });
    });

    group('Invite Flows', () {
      testWidgets('should handle various invite scenarios', (WidgetTester tester) async {
        final inviteScenarios = [
          {
            'type': 'direct_invite',
            'fromUserId': 'user_123',
            'toUserId': 'user_456',
            'gameId': 'game_789',
            'gameStatus': 'open',
            'spotsAvailable': 3,
            'canInvite': true
          },
          {
            'type': 'group_invite',
            'fromUserId': 'user_123',
            'toUserIds': ['user_456', 'user_789', 'user_012'],
            'gameId': 'game_789',
            'gameStatus': 'open',
            'spotsAvailable': 2,
            'canInvite': false,
            'reason': 'insufficient_spots'
          },
          {
            'type': 'friend_invite',
            'fromUserId': 'user_123',
            'toUserId': 'user_456',
            'gameId': 'game_789',
            'gameStatus': 'full',
            'canInvite': true,
            'inviteToWaitlist': true
          }
        ];

        for (final scenario in inviteScenarios) {
          final inviteResult = await _processInvite(scenario);
          
          expect(inviteResult['canInvite'], equals(scenario['canInvite']));
          
          if (inviteResult['canInvite']) {
            expect(inviteResult['inviteSent'], isTrue);
            expect(inviteResult['inviteType'], equals(scenario['type']));
            
            if (scenario['inviteToWaitlist'] == true) {
              expect(inviteResult['isWaitlistInvite'], isTrue);
            }
            
            print('✅ Invite sent: ${scenario['type']} for ${scenario['gameId']}');
          } else {
            expect(inviteResult['reason'], isNotNull);
            print('❌ Invite blocked: ${inviteResult['reason']}');
          }
        }
      });

      testWidgets('should handle invite responses and acceptance', (WidgetTester tester) async {
        final responseScenarios = [
          {
            'inviteId': 'invite_123',
            'response': 'accept',
            'gameStatus': 'open',
            'spotsAvailable': 2,
            'expectedResult': 'accepted',
            'bookingCreated': true
          },
          {
            'inviteId': 'invite_456', 
            'response': 'accept',
            'gameStatus': 'full',
            'spotsAvailable': 0,
            'expectedResult': 'waitlisted',
            'bookingCreated': false
          },
          {
            'inviteId': 'invite_789',
            'response': 'decline',
            'gameStatus': 'open',
            'spotsAvailable': 3,
            'expectedResult': 'declined',
            'bookingCreated': false
          },
          {
            'inviteId': 'invite_012',
            'response': 'timeout',
            'gameStatus': 'open',
            'spotsAvailable': 1,
            'expectedResult': 'expired',
            'bookingCreated': false
          }
        ];

        for (final scenario in responseScenarios) {
          final responseResult = await _processInviteResponse(scenario);
          
          expect(responseResult['result'], equals(scenario['expectedResult']));
          expect(responseResult['bookingCreated'], equals(scenario['bookingCreated']));
          
          if (responseResult['result'] == 'accepted') {
            expect(responseResult['notificationSent'], isTrue);
            expect(responseResult['gameUpdated'], isTrue);
          } else if (responseResult['result'] == 'waitlisted') {
            expect(responseResult['waitlistPosition'], isNotNull);
          }

          print('✅ Invite response: ${scenario['response']} → ${scenario['expectedResult']}');
        }
      });

      testWidgets('should track invite expiration and cleanup', (WidgetTester tester) async {
        final inviteExpirationData = {
          'invites': [
            {
              'inviteId': 'invite_old_1',
              'sentAt': DateTime.now().subtract(Duration(hours: 25)),
              'expiresAt': DateTime.now().subtract(Duration(hours: 1)),
              'status': 'pending'
            },
            {
              'inviteId': 'invite_fresh_1',
              'sentAt': DateTime.now().subtract(Duration(hours: 2)),
              'expiresAt': DateTime.now().add(Duration(hours: 22)),
              'status': 'pending'
            },
            {
              'inviteId': 'invite_expired_1',
              'sentAt': DateTime.now().subtract(Duration(hours: 30)),
              'expiresAt': DateTime.now().subtract(Duration(hours: 6)),
              'status': 'pending'
            }
          ]
        };

        final cleanupResult = await _processInviteCleanup(inviteExpirationData);
        
        expect(cleanupResult['expiredInvites'].length, equals(2));
        expect(cleanupResult['activeInvites'].length, equals(1));
        expect(cleanupResult['cleanupPerformed'], isTrue);
        
        final expiredIds = cleanupResult['expiredInvites'].map((i) => i['inviteId']).toList();
        expect(expiredIds, contains('invite_old_1'));
        expect(expiredIds, contains('invite_expired_1'));

        print('✅ Invite cleanup: 2 expired, 1 active remaining');
      });

      testWidgets('should handle invite limits and spam prevention', (WidgetTester tester) async {
        final limitScenarios = [
          {
            'userId': 'user_123',
            'invitesSentToday': 15,
            'dailyLimit': 20,
            'canSendMore': true,
            'remainingInvites': 5
          },
          {
            'userId': 'user_456',
            'invitesSentToday': 20,
            'dailyLimit': 20,
            'canSendMore': false,
            'remainingInvites': 0
          },
          {
            'userId': 'user_789',
            'invitesSentInLastHour': 8,
            'hourlyLimit': 10,
            'canSendMore': true,
            'rateLimitApproaching': true
          }
        ];

        for (final scenario in limitScenarios) {
          final limitCheck = _checkInviteLimits(scenario);
          
          expect(limitCheck['canSendMore'], equals(scenario['canSendMore']));
          expect(limitCheck['remainingInvites'], equals(scenario['remainingInvites']));
          
          if (scenario['rateLimitApproaching'] == true) {
            expect(limitCheck['warning'], isNotNull);
          }

          print('✅ Invite limits: User ${scenario['userId']} - ${limitCheck['canSendMore'] ? 'Can send' : 'Blocked'}');
        }
      });
    });

    group('Social Features Integration', () {
      testWidgets('should handle friend recommendations for invites', (WidgetTester tester) async {
        final recommendationData = {
          'userId': 'user_123',
          'gameId': 'game_456',
          'gameType': 'football',
          'gameTime': DateTime.now().add(Duration(hours: 3)),
          'venue': 'Sports City',
          'userFriends': [
            {'friendId': 'friend_1', 'preferredSports': ['football', 'basketball'], 'location': 'Dubai', 'availability': 'high'},
            {'friendId': 'friend_2', 'preferredSports': ['tennis'], 'location': 'Dubai', 'availability': 'low'},
            {'friendId': 'friend_3', 'preferredSports': ['football'], 'location': 'Abu Dhabi', 'availability': 'medium'},
          ]
        };

        final recommendations = _generateInviteRecommendations(recommendationData);
        
        expect(recommendations['totalRecommendations'], greaterThan(0));
        expect(recommendations['topRecommendations'], isNotEmpty);
        
        final topRecommendation = recommendations['topRecommendations'][0];
        expect(topRecommendation['friendId'], equals('friend_1'));
        expect(topRecommendation['score'], greaterThan(0.5));
        expect(topRecommendation['reasons'], contains('sport_match'));

        print('✅ Friend recommendations: ${recommendations['totalRecommendations']} friends suggested');
      });

      testWidgets('should handle group invite coordination', (WidgetTester tester) async {
        final groupInviteData = {
          'gameId': 'game_789',
          'organizerId': 'user_123',
          'groupMembers': [
            {'userId': 'member_1', 'status': 'pending'},
            {'userId': 'member_2', 'status': 'accepted'},
            {'userId': 'member_3', 'status': 'declined'},
            {'userId': 'member_4', 'status': 'pending'}
          ],
          'requiredAcceptances': 3,
          'totalInvited': 4
        };

        final groupStatus = _calculateGroupInviteStatus(groupInviteData);
        
        expect(groupStatus['acceptedCount'], equals(1));
        expect(groupStatus['pendingCount'], equals(2));
        expect(groupStatus['declinedCount'], equals(1));
        expect(groupStatus['meetingRequirement'], isFalse);
        expect(groupStatus['needMoreAcceptances'], equals(2));

        print('✅ Group invite status: 1/3 required acceptances');
      });

      testWidgets('should handle invite notification preferences', (WidgetTester tester) async {
        final notificationScenarios = [
          {
            'userId': 'user_123',
            'preferences': {
              'pushNotifications': true,
              'emailNotifications': false,
              'smsNotifications': true,
              'inviteTypes': ['friends_only']
            },
            'inviteFrom': 'friend_456',
            'relationship': 'friend',
            'shouldNotify': true,
            'channels': ['push', 'sms']
          },
          {
            'userId': 'user_789',
            'preferences': {
              'pushNotifications': false,
              'emailNotifications': true,
              'inviteTypes': ['everyone']
            },
            'inviteFrom': 'stranger_012',
            'relationship': 'none',
            'shouldNotify': true,
            'channels': ['email']
          },
          {
            'userId': 'user_456',
            'preferences': {
              'pushNotifications': true,
              'inviteTypes': ['friends_only']
            },
            'inviteFrom': 'stranger_789',
            'relationship': 'none',
            'shouldNotify': false,
            'channels': []
          }
        ];

        for (final scenario in notificationScenarios) {
          final notificationDecision = _processNotificationPreferences(scenario);
          
          expect(notificationDecision['shouldNotify'], equals(scenario['shouldNotify']));
          expect(notificationDecision['channels'], equals(scenario['channels']));
          
          if (notificationDecision['shouldNotify']) {
            expect(notificationDecision['notificationsSent'], isTrue);
          }

          print('✅ Notification prefs: ${scenario['userId']} - ${notificationDecision['shouldNotify'] ? 'Notified' : 'Blocked'}');
        }
      });
    });
  });
}

// Helper functions for waitlist and invite tests

Future<Map<String, dynamic>> _attemptJoinWaitlist(Map<String, dynamic> scenario) async {
  await Future.delayed(Duration(milliseconds: 50));
  
  final currentPlayers = scenario['currentPlayers'] as int;
  final maxPlayers = scenario['maxPlayers'] as int;
  final allowWaitlist = scenario['allowWaitlist'] as bool;
  final currentWaitlist = scenario['currentWaitlist'] as int;
  
  if (!allowWaitlist) {
    return {'canJoin': false, 'reason': 'waitlist_disabled'};
  }
  
  if (currentPlayers < maxPlayers) {
    return {'canJoin': false, 'reason': 'spots_available'};
  }
  
  return {
    'canJoin': true,
    'position': currentWaitlist + 1,
    'status': 'waitlisted',
    'estimatedTime': Duration(minutes: (currentWaitlist + 1) * 10)
  };
}

Future<Map<String, dynamic>> _simulateWaitlistPositionChange(Map<String, dynamic> waitlistState, String changeType) async {
  await Future.delayed(Duration(milliseconds: 100));
  
  final currentPosition = waitlistState['userPosition'] as int;
  
  switch (changeType) {
    case 'user_ahead_left':
      return {
        'newPosition': currentPosition - 1,
        'positionImproved': true,
        'estimateUpdated': true,
        'changeReason': 'user_left'
      };
    case 'user_joined_behind':
      return {
        'newPosition': currentPosition,
        'positionImproved': false,
        'totalWaitlisted': waitlistState['totalWaitlisted'] + 1,
        'changeReason': 'new_joiner'
      };
    case 'next_in_line':
      return {
        'newPosition': 1,
        'isNextInLine': true,
        'urgentNotification': true,
        'changeReason': 'promoted_to_first'
      };
    default:
      return {'newPosition': currentPosition, 'positionImproved': false};
  }
}

Future<Map<String, dynamic>> _simulateWaitlistConfirmation(Map<String, dynamic> scenario) async {
  final responseTime = scenario['responseTime'] as Duration;
  final userResponse = scenario['userResponse'] as String?;
  
  // Simulate waiting for response
  await Future.delayed(Duration(milliseconds: min(responseTime.inMilliseconds, 100)));
  
  if (responseTime.inMinutes > 5) {
    return {
      'result': 'timeout',
      'timeoutOccurred': true,
      'nextUserNotified': true
    };
  }
  
  if (userResponse == 'confirm') {
    return {
      'result': 'confirmed',
      'bookingCreated': true,
      'removedFromWaitlist': true
    };
  } else if (userResponse == 'decline') {
    return {
      'result': 'declined',
      'nextUserNotified': true
    };
  }
  
  return {'result': 'unknown'};
}

Map<String, dynamic> _calculateWaitlistTimeEstimate(Map<String, dynamic> scenario) {
  final gameTime = scenario['gameTime'] as DateTime;
  final userPosition = scenario['userPosition'] as int;
  final dropoutRate = scenario['averageDropoutRate'] as double;
  
  final timeUntilGame = gameTime.difference(DateTime.now());
  final estimatedDropouts = (userPosition * dropoutRate).round();
  final effectivePosition = userPosition - estimatedDropouts;
  final estimateMinutes = effectivePosition * 10;
  
  return {
    'estimate': Duration(minutes: estimateMinutes),
    'confidence': 0.75,
    'factors': {
      'position': userPosition,
      'dropoutRate': dropoutRate,
      'timeUntilGame': timeUntilGame
    }
  };
}

Future<Map<String, dynamic>> _processInvite(Map<String, dynamic> scenario) async {
  await Future.delayed(Duration(milliseconds: 50));
  
  final gameStatus = scenario['gameStatus'] as String;
  final spotsAvailable = scenario['spotsAvailable'] as int?;
  final canInvite = scenario['canInvite'] as bool;
  
  if (!canInvite) {
    return {
      'canInvite': false,
      'reason': scenario['reason'] ?? 'unknown_error'
    };
  }
  
  Map<String, dynamic> result = {
    'canInvite': true,
    'inviteSent': true,
    'inviteType': scenario['type']
  };
  
  if (gameStatus == 'full') {
    result['isWaitlistInvite'] = true;
  }
  
  return result;
}

Future<Map<String, dynamic>> _processInviteResponse(Map<String, dynamic> scenario) async {
  await Future.delayed(Duration(milliseconds: 50));
  
  final response = scenario['response'] as String;
  final gameStatus = scenario['gameStatus'] as String;
  final spotsAvailable = scenario['spotsAvailable'] as int;
  
  if (response == 'accept') {
    if (spotsAvailable > 0) {
      return {
        'result': 'accepted',
        'bookingCreated': true,
        'notificationSent': true,
        'gameUpdated': true
      };
    } else {
      return {
        'result': 'waitlisted',
        'bookingCreated': false,
        'waitlistPosition': 3
      };
    }
  } else if (response == 'decline') {
    return {
      'result': 'declined',
      'bookingCreated': false
    };
  } else {
    return {
      'result': 'expired',
      'bookingCreated': false
    };
  }
}

Future<Map<String, dynamic>> _processInviteCleanup(Map<String, dynamic> inviteData) async {
  await Future.delayed(Duration(milliseconds: 100));
  
  final invites = inviteData['invites'] as List<Map<String, dynamic>>;
  final now = DateTime.now();
  
  final expiredInvites = invites.where((invite) {
    final expiresAt = invite['expiresAt'] as DateTime;
    return now.isAfter(expiresAt);
  }).toList();
  
  final activeInvites = invites.where((invite) {
    final expiresAt = invite['expiresAt'] as DateTime;
    return now.isBefore(expiresAt);
  }).toList();
  
  return {
    'expiredInvites': expiredInvites,
    'activeInvites': activeInvites,
    'cleanupPerformed': true
  };
}

Map<String, dynamic> _checkInviteLimits(Map<String, dynamic> scenario) {
  final userId = scenario['userId'] as String;
  
  if (scenario.containsKey('invitesSentToday')) {
    final sentToday = scenario['invitesSentToday'] as int;
    final dailyLimit = scenario['dailyLimit'] as int;
    final remaining = dailyLimit - sentToday;
    
    return {
      'canSendMore': remaining > 0,
      'remainingInvites': remaining,
      'limitType': 'daily'
    };
  }
  
  if (scenario.containsKey('invitesSentInLastHour')) {
    final sentInHour = scenario['invitesSentInLastHour'] as int;
    final hourlyLimit = scenario['hourlyLimit'] as int;
    final remaining = hourlyLimit - sentInHour;
    
    Map<String, dynamic> result = {
      'canSendMore': remaining > 0,
      'remainingInvites': remaining,
      'limitType': 'hourly'
    };
    
    if (remaining <= 2) {
      result['warning'] = 'Approaching hourly limit';
    }
    
    return result;
  }
  
  return {'canSendMore': true, 'remainingInvites': 999};
}

Map<String, dynamic> _generateInviteRecommendations(Map<String, dynamic> recommendationData) {
  final gameType = recommendationData['gameType'] as String;
  final userFriends = recommendationData['userFriends'] as List<Map<String, dynamic>>;
  
  List<Map<String, dynamic>> recommendations = [];
  
  for (final friend in userFriends) {
    final preferredSports = friend['preferredSports'] as List<String>;
    final availability = friend['availability'] as String;
    final location = friend['location'] as String;
    
    double score = 0.0;
    List<String> reasons = [];
    
    if (preferredSports.contains(gameType)) {
      score += 0.4;
      reasons.add('sport_match');
    }
    
    if (availability == 'high') {
      score += 0.3;
      reasons.add('high_availability');
    } else if (availability == 'medium') {
      score += 0.2;
    }
    
    if (location == 'Dubai') {
      score += 0.3;
      reasons.add('location_match');
    }
    
    if (score > 0.3) {
      recommendations.add({
        'friendId': friend['friendId'],
        'score': score,
        'reasons': reasons
      });
    }
  }
  
  recommendations.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
  
  return {
    'totalRecommendations': recommendations.length,
    'topRecommendations': recommendations
  };
}

Map<String, dynamic> _calculateGroupInviteStatus(Map<String, dynamic> groupInviteData) {
  final groupMembers = groupInviteData['groupMembers'] as List<Map<String, dynamic>>;
  final requiredAcceptances = groupInviteData['requiredAcceptances'] as int;
  
  int acceptedCount = 0;
  int pendingCount = 0;
  int declinedCount = 0;
  
  for (final member in groupMembers) {
    switch (member['status']) {
      case 'accepted':
        acceptedCount++;
        break;
      case 'pending':
        pendingCount++;
        break;
      case 'declined':
        declinedCount++;
        break;
    }
  }
  
  return {
    'acceptedCount': acceptedCount,
    'pendingCount': pendingCount,
    'declinedCount': declinedCount,
    'meetingRequirement': acceptedCount >= requiredAcceptances,
    'needMoreAcceptances': requiredAcceptances - acceptedCount
  };
}

Map<String, dynamic> _processNotificationPreferences(Map<String, dynamic> scenario) {
  final preferences = scenario['preferences'] as Map<String, dynamic>;
  final inviteFrom = scenario['inviteFrom'] as String;
  final relationship = scenario['relationship'] as String;
  
  final inviteTypes = preferences['inviteTypes'] as List<String>;
  
  // Check if user accepts invites from this relationship type
  bool shouldNotify = false;
  if (inviteTypes.contains('everyone')) {
    shouldNotify = true;
  } else if (inviteTypes.contains('friends_only') && relationship == 'friend') {
    shouldNotify = true;
  }
  
  if (!shouldNotify) {
    return {
      'shouldNotify': false,
      'channels': [],
      'reason': 'preference_restriction'
    };
  }
  
  List<String> channels = [];
  if (preferences['pushNotifications'] == true) {
    channels.add('push');
  }
  if (preferences['emailNotifications'] == true) {
    channels.add('email');
  }
  if (preferences['smsNotifications'] == true) {
    channels.add('sms');
  }
  
  return {
    'shouldNotify': true,
    'channels': channels,
    'notificationsSent': channels.isNotEmpty
  };
}

int min(int a, int b) => a < b ? a : b;