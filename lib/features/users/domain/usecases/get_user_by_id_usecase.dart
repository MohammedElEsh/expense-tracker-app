import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<UserEntity?> call(String id) => repository.getUserById(id);
}
