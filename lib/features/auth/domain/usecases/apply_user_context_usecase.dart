import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

class ApplyUserContextUseCase {
  final AuthRepository repository;

  const ApplyUserContextUseCase(this.repository);

  Future<void> call(UserEntity user) => repository.applyUserContext(user);
}
