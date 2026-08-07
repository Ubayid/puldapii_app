import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:puldapii/models/app_notification_model.dart';
import 'package:puldapii/utils/services/notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService notificationService;

  NotificationCubit(this.notificationService)
    : super(const NotificationInitial());

  Future<void> loadUnreadCount() async {
    try {
      final count = await notificationService.getUnreadCount();

      emit(
        NotificationLoaded(
          hasUnread: count > 0,
          unreadCount: count,
          notifications: state.notifications,
        ),
      );
    } catch (e) {
      emit(
        NotificationLoaded(
          hasUnread: state.hasUnread,
          unreadCount: state.unreadCount,
          notifications: state.notifications,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshNotifications() async {
    try {
      emit(
        NotificationLoaded(
          hasUnread: state.hasUnread,
          unreadCount: state.unreadCount,
          notifications: state.notifications,
          isLoading: true,
        ),
      );

      final notifications = await notificationService.getNotifications();
      final unreadCount = await notificationService.getUnreadCount();

      emit(
        NotificationLoaded(
          hasUnread: unreadCount > 0,
          unreadCount: unreadCount,
          notifications: notifications,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        NotificationLoaded(
          hasUnread: state.hasUnread,
          unreadCount: state.unreadCount,
          notifications: state.notifications,
          isLoading: false,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await notificationService.markAsRead(notificationId);

      final updatedNotifications = state.notifications.map((item) {
        if (item.id == notificationId) {
          return item.copyWith(isRead: true);
        }

        return item;
      }).toList();

      final unreadCount = updatedNotifications
          .where((item) => !item.isRead)
          .length;

      emit(
        NotificationLoaded(
          hasUnread: unreadCount > 0,
          unreadCount: unreadCount,
          notifications: updatedNotifications,
        ),
      );
    } catch (e) {
      emit(
        NotificationLoaded(
          hasUnread: state.hasUnread,
          unreadCount: state.unreadCount,
          notifications: state.notifications,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationService.markAllAsRead();

      final updatedNotifications = state.notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();

      emit(
        NotificationLoaded(
          hasUnread: false,
          unreadCount: 0,
          notifications: updatedNotifications,
        ),
      );
    } catch (e) {
      emit(
        NotificationLoaded(
          hasUnread: state.hasUnread,
          unreadCount: state.unreadCount,
          notifications: state.notifications,
          message: e.toString(),
        ),
      );
    }
  }
}
