/// Notification model for app notifications
///
/// Represents in-app notifications for expense status changes
/// and approval requests.

/// Notification action that can be taken when tapping a notification
class NotificationAction {
  final String type;
  final String screen;
  final Map<String, dynamic> params;

  NotificationAction({
    required this.type,
    required this.screen,
    required this.params,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      type: json['type'] ?? 'navigate',
      screen: json['screen'] ?? '',
      params: (json['params'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'screen': screen,
      'params': params,
    };
  }
}

/// Application notification
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final String time;
  final bool read;
  final String icon;
  final NotificationAction action;
  final int expenseId;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
    this.icon = 'info',
    required this.action,
    required this.expenseId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? json.hashCode,
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? DateTime.now().toIso8601String(),
      read: json['read'] ?? false,
      icon: json['icon'] ?? 'info',
      action: NotificationAction.fromJson(
        json['action'] ?? {'type': 'navigate', 'screen': '', 'params': {}},
      ),
      expenseId: json['expenseId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'time': time,
      'read': read,
      'icon': icon,
      'action': action.toJson(),
      'expenseId': expenseId,
    };
  }

  /// Create a copy of this notification with some fields replaced
  AppNotification copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    String? time,
    bool? read,
    String? icon,
    NotificationAction? action,
    int? expenseId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      read: read ?? this.read,
      icon: icon ?? this.icon,
      action: action ?? this.action,
      expenseId: expenseId ?? this.expenseId,
    );
  }

  /// Get parsed DateTime from time string
  DateTime? get dateTime {
    try {
      return DateTime.parse(time);
    } catch (e) {
      return null;
    }
  }

  /// Alias for backward compatibility - returns the same as 'time'
  String get timestamp => time;
}
