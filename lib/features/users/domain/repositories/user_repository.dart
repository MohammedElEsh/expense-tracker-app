import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';

/// Repository interface for company user management (business mode).
abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
  Future<UserEntity?> getUserById(String id);
  Future<UserEntity> createUser(UserEntity entity, {required String password});
  Future<UserEntity> updateUser(UserEntity entity);
  Future<void> deleteUser(String id);
}
