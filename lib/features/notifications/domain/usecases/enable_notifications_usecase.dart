import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';

class EnableNotificationsUseCase {
  final NotificationRepository _repository;

  const EnableNotificationsUseCase(this._repository);

  Future<void> call() => _repository.enable();
}
