/// Notification Model
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final String time;
  final bool read;
  final String icon;
  final NotificationAction? action;
  final int? expenseId;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
    required this.icon,
    this.action,
    this.expenseId,
  });

  // Alias for time for compatibility
  String get timestamp => time;

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

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as int,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      time: map['time'] as String,
      read: map['read'] as bool? ?? false,
      icon: map['icon'] as String,
      action: map['action'] != null
          ? NotificationAction.fromMap(map['action'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Notification Action Model
class NotificationAction {
  final String type;
  final String screen;
  final Map<String, dynamic>? params;

  NotificationAction({
    required this.type,
    required this.screen,
    this.params,
  });

  factory NotificationAction.fromMap(Map<String, dynamic> map) {
    return NotificationAction(
      type: map['type'] as String,
      screen: map['screen'] as String,
      params: map['params'] as Map<String, dynamic>?,
    );
  }
}
