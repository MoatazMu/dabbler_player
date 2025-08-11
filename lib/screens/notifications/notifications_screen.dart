import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'All';
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.check),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical),
            onSelected: (String value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'settings':
                  _showNotificationSettings();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(LucideIcons.settings, size: 16),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildStatsSection(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _notificationService.refreshNotifications(),
              child: _buildNotificationsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = ['All', 'Games', 'Bookings', 'Social', 'Achievements'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _showOnlyUnread,
                onChanged: (value) {
                  setState(() {
                    _showOnlyUnread = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Text(
                'Show only unread',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _notificationService,
      builder: (context, child) {
        final unreadCount = _notificationService.unreadCount;
        final totalCount = _notificationService.notifications.length;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.bell,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unreadCount unread',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$totalCount total notifications',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    '$unreadCount new',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsList() {
    return AnimatedBuilder(
      animation: _notificationService,
      builder: (context, child) {
        if (_notificationService.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final notifications = _getFilteredNotifications();
        
        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        final groupedNotifications = _getGroupedNotifications(notifications);
        
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...groupedNotifications.entries.map((entry) {
                return _buildNotificationGroup(entry.key, entry.value);
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationGroup(String dateLabel, List<NotificationModel> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: double.infinity,
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        ...notifications.map((notification) {
          return _buildNotificationCard(notification);
        }),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead 
          ? Theme.of(context).colorScheme.surface 
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification.type, notification.priority),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 8, top: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        _buildPriorityBadge(notification.priority),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(
                            LucideIcons.moreVertical,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onSelected: (String value) {
                            switch (value) {
                              case 'mark_read':
                                _notificationService.markAsRead(notification.id);
                                break;
                              case 'mark_unread':
                                _notificationService.markAsUnread(notification.id);
                                break;
                              case 'delete':
                                _notificationService.deleteNotification(notification.id);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: notification.isRead ? 'mark_unread' : 'mark_read',
                              child: Row(
                                children: [
                                  Icon(
                                    notification.isRead ? LucideIcons.eyeOff : LucideIcons.eye,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(notification.isRead ? 'Mark as Unread' : 'Mark as Read'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        if (notification.actionText != null) ...[
                          const SizedBox(width: 12),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _handleActionTap(notification),
                            child: Text(
                              notification.actionText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type, NotificationPriority priority) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case NotificationType.gameInvite:
        iconData = LucideIcons.userPlus;
        backgroundColor = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        break;
      case NotificationType.gameUpdate:
        iconData = LucideIcons.gamepad2;
        backgroundColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        break;
      case NotificationType.bookingConfirmation:
      case NotificationType.bookingReminder:
        iconData = LucideIcons.calendar;
        backgroundColor = Colors.purple.shade50;
        iconColor = Colors.purple.shade700;
        break;
      case NotificationType.friendRequest:
        iconData = LucideIcons.users;
        backgroundColor = Colors.teal.shade50;
        iconColor = Colors.teal.shade700;
        break;
      case NotificationType.achievement:
        iconData = LucideIcons.award;
        backgroundColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade700;
        break;
      case NotificationType.loyaltyPoints:
        iconData = LucideIcons.gift;
        backgroundColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
        break;
      case NotificationType.systemAlert:
        iconData = LucideIcons.alertTriangle;
        backgroundColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        break;
      default:
        iconData = LucideIcons.bell;
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: priority == NotificationPriority.urgent
          ? Border.all(color: Colors.red.shade300, width: 2)
          : null,
      ),
      child: Icon(
        iconData,
        size: 16,
        color: iconColor,
      ),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority) {
    if (priority == NotificationPriority.low || priority == NotificationPriority.normal) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    String text;

    switch (priority) {
      case NotificationPriority.high:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'High';
        break;
      case NotificationPriority.urgent:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Urgent';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bell,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyUnread ? 'No unread notifications' : 'No notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyUnread
              ? 'All caught up! Check back later for updates.'
              : 'You\'re all set! Notifications will appear here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications() {
    var notifications = _notificationService.notifications;

    // Filter by type
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Games':
          notifications = notifications.where((n) => 
            n.type == NotificationType.gameInvite ||
            n.type == NotificationType.gameUpdate
          ).toList();
          break;
        case 'Bookings':
          notifications = notifications.where((n) => 
            n.type == NotificationType.bookingConfirmation ||
            n.type == NotificationType.bookingReminder
          ).toList();
          break;
        case 'Social':
          notifications = notifications.where((n) => 
            n.type == NotificationType.friendRequest
          ).toList();
          break;
        case 'Achievements':
          notifications = notifications.where((n) => 
            n.type == NotificationType.achievement ||
            n.type == NotificationType.loyaltyPoints
          ).toList();
          break;
      }
    }

    // Filter by read status
    if (_showOnlyUnread) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    return notifications;
  }

  Map<String, List<NotificationModel>> _getGroupedNotifications(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (final notification in notifications) {
      final dateKey = notification.formattedDate;
      grouped[dateKey] ??= [];
      grouped[dateKey]!.add(notification);
    }
    
    return grouped;
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }
    
    // Handle navigation if action route exists
    if (notification.actionRoute != null) {
      _handleActionTap(notification);
    }
  }

  void _handleActionTap(NotificationModel notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action: ${notification.actionText} - ${notification.actionRoute}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _notificationService.clearAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationSettings() {
    context.push('/notification_settings');
  }
} 