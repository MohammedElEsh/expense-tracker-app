import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';

class RequestNotificationPermissionUseCase {
  final NotificationRepository _repository;

  const RequestNotificationPermissionUseCase(this._repository);

  Future<void> call() => _repository.requestPermission();
}
