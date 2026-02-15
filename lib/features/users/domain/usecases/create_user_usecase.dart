import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  Future<UserEntity> call(UserEntity entity, {required String password}) {
    return repository.createUser(entity, password: password);
  }
}
