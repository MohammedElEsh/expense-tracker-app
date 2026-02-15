import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<void> call(String id) => repository.deleteUser(id);
}
