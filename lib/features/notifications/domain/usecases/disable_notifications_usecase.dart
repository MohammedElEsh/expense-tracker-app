import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';

class DisableNotificationsUseCase {
  final NotificationRepository _repository;

  const DisableNotificationsUseCase(this._repository);

  Future<void> call() => _repository.disable();
}
