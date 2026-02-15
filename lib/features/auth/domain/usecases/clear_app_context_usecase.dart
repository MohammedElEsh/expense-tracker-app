import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

class ClearAppContextUseCase {
  final AuthRepository repository;

  const ClearAppContextUseCase(this.repository);

  Future<void> call() => repository.clearAppContext();
}
