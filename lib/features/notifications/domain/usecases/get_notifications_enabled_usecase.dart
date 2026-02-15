import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsEnabledUseCase {
  final NotificationRepository _repository;

  const GetNotificationsEnabledUseCase(this._repository);

  Future<bool> call() => _repository.areEnabled();
}
