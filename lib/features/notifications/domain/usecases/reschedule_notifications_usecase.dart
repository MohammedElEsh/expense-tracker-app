import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';

class RescheduleNotificationsUseCase {
  final NotificationRepository _repository;

  const RescheduleNotificationsUseCase(this._repository);

  Future<void> call() => _repository.reschedule();
}
