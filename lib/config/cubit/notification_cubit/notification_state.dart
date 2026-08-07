part of 'notification_cubit.dart';

sealed class NotificationState extends Equatable {
  final bool hasUnread;
  final int unreadCount;
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? message;

  const NotificationState({
    this.hasUnread = false,
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.message,
  });

  @override
  List<Object?> get props => [
    hasUnread,
    unreadCount,
    notifications,
    isLoading,
    message,
  ];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial() : super();
}

final class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required super.hasUnread,
    required super.unreadCount,
    required super.notifications,
    super.isLoading = false,
    super.message,
  });
}
