import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_notification_service.dart';
import 'package:expense_tracker/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final LocalNotificationDataSource _dataSource;
  final RecurringExpenseNotificationService _notificationService;

  NotificationRepositoryImpl({
    required LocalNotificationDataSource dataSource,
    required RecurringExpenseNotificationService notificationService,
  })  : _dataSource = dataSource,
        _notificationService = notificationService;

  @override
  Future<bool> areEnabled() => _dataSource.getEnabled();

  @override
  Future<void> enable() async {
    await _dataSource.setEnabled(true);
    await _dataSource.reschedule();
  }

  @override
  Future<void> disable() async {
    await _dataSource.setEnabled(false);
    // TODO: Optionally cancel all scheduled notifications.
  }

  @override
  Future<void> reschedule() => _dataSource.reschedule();

  @override
  Future<void> requestPermission() => _notificationService.requestPermission();
}
