import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/users/data/datasources/user_remote_datasource.dart';
import 'package:expense_tracker/features/users/data/models/user_model.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;

  UserRepositoryImpl({required UserRemoteDataSource remote}) : _remote = remote;

  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'accountant':
        return UserRole.accountant;
      case 'employee':
        return UserRole.employee;
      case 'auditor':
        return UserRole.auditor;
      default:
        return UserRole.employee;
    }
  }

  static String _roleToString(UserRole role) => role.name;

  static UserEntity _modelToEntity(UserModel m) {
    return UserEntity(
      id: m.id,
      name: m.name,
      email: m.email,
      role: _roleFromString(m.role),
      isActive: m.isActive,
      createdAt: m.createdAt,
      lastLoginAt: m.lastLoginAt,
      phone: m.phone,
      department: m.department,
      employeeId: m.employeeId,
    );
  }

  @override
  Future<List<UserEntity>> getUsers() async {
    final list = await _remote.getUsers();
    return list.map(_modelToEntity).toList();
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    final model = await _remote.getUserById(id);
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<UserEntity> createUser(UserEntity entity, {required String password}) async {
    if (entity.role == UserRole.owner) {
      throw ValidationException('Cannot assign owner role via add user');
    }
    final model = await _remote.addUser(
      name: entity.name,
      email: entity.email,
      password: password,
      role: _roleToString(entity.role),
    );
    return _modelToEntity(model);
  }

  @override
  Future<UserEntity> updateUser(UserEntity entity) async {
    final current = await _remote.getUserById(entity.id);
    if (current == null) {
      throw ServerException('User not found', statusCode: 404);
    }
    UserModel? result;
    if (entity.name.isNotEmpty && entity.name != current.name) {
      result = await _remote.updateUserName(userId: entity.id, name: entity.name);
    }
    if (entity.role != UserRole.owner &&
        _roleFromString(current.role) != entity.role) {
      result = await _remote.updateUserRole(
        userId: entity.id,
        role: _roleToString(entity.role),
      );
    }
    result ??= await _remote.getUserById(entity.id);
    return result != null ? _modelToEntity(result) : _modelToEntity(current);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _remote.deleteUser(id);
  }
}
