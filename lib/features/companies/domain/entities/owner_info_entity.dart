/// Domain entity for company owner info.
class OwnerInfoEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const OwnerInfoEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });
}
