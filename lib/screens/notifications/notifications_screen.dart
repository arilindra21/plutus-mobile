import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../models/notification.dart';
import '../../widgets/layout/bottom_navigation.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildNotificationList(context)),
            const AppBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final unreadCount = appProvider.notifications.where((n) => !n.read).length;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (unreadCount > 0)
                GestureDetector(
                  onTap: () => appProvider.markAllNotificationsRead(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationList(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final notifications = appProvider.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.bell,
                    size: 36,
                    color: Color(0xFF007AFF),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're all caught up!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Group notifications by date
        final today = DateTime.now();
        final todayNotifications = <AppNotification>[];
        final yesterdayNotifications = <AppNotification>[];
        final olderNotifications = <AppNotification>[];

        for (final notification in notifications) {
          final notifDate = DateTime.tryParse(notification.timestamp) ?? today;
          final diff = today.difference(notifDate).inDays;

          if (diff == 0) {
            todayNotifications.add(notification);
          } else if (diff == 1) {
            yesterdayNotifications.add(notification);
          } else {
            olderNotifications.add(notification);
          }
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (todayNotifications.isNotEmpty) ...[
              _buildSectionHeader('Today'),
              ...todayNotifications.map((n) => _NotificationCard(
                    notification: n,
                    onTap: () => _handleNotificationTap(context, n),
                  )),
            ],
            if (yesterdayNotifications.isNotEmpty) ...[
              _buildSectionHeader('Yesterday'),
              ...yesterdayNotifications.map((n) => _NotificationCard(
                    notification: n,
                    onTap: () => _handleNotificationTap(context, n),
                  )),
            ],
            if (olderNotifications.isNotEmpty) ...[
              _buildSectionHeader('Earlier'),
              ...olderNotifications.map((n) => _NotificationCard(
                    notification: n,
                    onTap: () => _handleNotificationTap(context, n),
                  )),
            ],
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    final appProvider = context.read<AppProvider>();
    appProvider.markNotificationRead(notification.id);

    // Navigate based on notification type
    if (notification.expenseId != null) {
      final apiExpenseProvider = context.read<ApiExpenseProvider>();
      try {
        final expense = apiExpenseProvider.expenses.firstWhere(
          (exp) => exp.id == notification.expenseId,
        );
        apiExpenseProvider.setSelectedExpense(expense);
        appProvider.navigateTo('transactionDetail');
      } catch (e) {
        // Expense not found in current list
        // Could fetch it from API or show an error
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notification.read ? Colors.white : const Color(0xFF007AFF).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: notification.read
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF007AFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'approval':
        return CupertinoIcons.checkmark_circle_fill;
      case 'rejection':
        return CupertinoIcons.xmark_circle_fill;
      case 'reminder':
        return CupertinoIcons.clock_fill;
      case 'info':
        return CupertinoIcons.info_circle_fill;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      default:
        return CupertinoIcons.bell_fill;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'approval':
        return const Color(0xFF30D158);
      case 'rejection':
        return const Color(0xFFFF3B30);
      case 'reminder':
        return const Color(0xFFFF9500);
      case 'info':
        return const Color(0xFF007AFF);
      case 'warning':
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF007AFF);
    }
  }

  String _formatTime(String timestamp) {
    final date = DateTime.tryParse(timestamp);
    if (date == null) return timestamp;

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
