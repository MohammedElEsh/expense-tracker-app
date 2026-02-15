// Barrel: re-export domain entities and data model for backward compatibility.
// Prefer importing from domain/entities in presentation and domain layers.

import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';

export 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
export 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';
export 'package:expense_tracker/features/accounts/data/models/account_model.dart';

/// Alias so existing code using [Account] refers to the domain entity.
typedef Account = AccountEntity;
