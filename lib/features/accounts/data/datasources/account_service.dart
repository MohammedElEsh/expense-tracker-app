import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/features/accounts/data/models/account_model.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';

class AccountService {
  final ApiService _apiService;
  final PrefHelper _prefHelper;
  final AppContext _appContext;

  List<AccountModel>? _cachedAccounts;
  static const String _defaultAccountKey = 'default_account_id';

  AccountService({
    required ApiService apiService,
    required PrefHelper prefHelper,
    required AppContext appContext,
  })  : _apiService = apiService,
        _prefHelper = prefHelper,
        _appContext = appContext;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Clear cached accounts
  void clearCache() {
    _cachedAccounts = null;
    debugPrint('🗑️ Account cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Load all accounts from API
  /// GET /api/accounts
  Future<List<AccountModel>> loadAccounts() async {
    try {
      final currentAppMode = _appContext.appMode;
      final companyId = _appContext.companyId;

      debugPrint(
        '🔍 loadAccounts - Mode: $currentAppMode, Company: $companyId',
      );

      final Map<String, dynamic> queryParams = {'appMode': currentAppMode.name};

      if (currentAppMode == AppMode.business && companyId != null) {
        queryParams['companyId'] = companyId;
      }

      final response = await _apiService.get(
        '/api/accounts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List
                ? response.data
                : (response.data['accounts'] ?? response.data['data'] ?? []);

        final accounts =
            data
                .map((json) => AccountModel.fromMap(json as Map<String, dynamic>))
                .toList();

        // Cache the accounts
        _cachedAccounts = accounts;

        debugPrint('✅ Loaded ${accounts.length} accounts from API');
        for (final account in accounts) {
          debugPrint(
            '💰 Account: ${account.name} - Balance: ${account.balance}',
          );
        }

        return accounts;
      }

      throw ServerException(
        'Failed to load accounts',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading accounts: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading accounts: $e');
    }
  }

  /// Create a new account via API
  /// POST /api/accounts
  ///
  /// Request Body:
  /// {
  ///   "name": "Account Name",
  ///   "type": "cash|bank|credit|debit|digital|gift|investment|savings",
  ///   "balance": 5000,
  ///   "currency": "SAR|USD|EUR|GBP|JPY|EGP|AED",
  ///   "isDefault": false,
  ///   "description": "Optional description"
  /// }
  ///
  /// Response: { "success": true, "account": { ... } }
  Future<AccountModel> addAccount(AccountModel account) async {
    try {
      final currentAppMode = _appContext.appMode;
      final companyId = _appContext.companyId;

      debugPrint('➕ Creating account: ${account.name}');

      final currencyCode = _appContext.getCurrencyCode(account.currency);
      debugPrint('💱 Currency: ${account.currency} → $currencyCode');

      final Map<String, dynamic> requestBody = {
        'name': account.name,
        'type': account.type.apiValue,
        'balance': account.balance,
        'currency': currencyCode,
        'isDefault': false,
        'description': account.description ?? '',
        'appMode': currentAppMode.name,
      };

      if (currentAppMode == AppMode.business && companyId != null) {
        requestBody['companyId'] = companyId;
      }

      debugPrint('📤 POST /api/accounts');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post(
        '/api/accounts',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse response: { "success": true, "account": { ... } }
        final responseData = response.data as Map<String, dynamic>;

        // Extract account from nested "account" object
        final Map<String, dynamic> accountJson;
        if (responseData.containsKey('account') &&
            responseData['account'] is Map) {
          accountJson = responseData['account'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          // Direct account object (fallback)
          accountJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing account object');
        }

        final newAccount = AccountModel.fromMap(accountJson);

        // Clear cache to force fresh reload
        clearCache();

        debugPrint('✅ Account created successfully: ${newAccount.id}');
        debugPrint(
          '✅ Name: ${newAccount.name}, Balance: ${newAccount.balance}',
        );
        return newAccount;
      }

      throw ServerException(
        'Failed to create account',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating account: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create account: $e');
    }
  }

  /// Update an existing account
  /// PUT /api/accounts/:id
  Future<AccountModel> updateAccount(AccountModel account) async {
    try {
      debugPrint('🔄 Updating account: ${account.id}');

      final Map<String, dynamic> accountData = account.toMap();

      final response = await _apiService.put(
        '/api/accounts/${account.id}',
        data: accountData,
      );

      if (response.statusCode == 200) {
        final updatedAccount = AccountModel.fromMap(
          response.data is Map
              ? response.data
              : response.data['account'] ?? response.data['data'],
        );

        // Update cache
        if (_cachedAccounts != null) {
          final index = _cachedAccounts!.indexWhere((a) => a.id == account.id);
          if (index != -1) {
            _cachedAccounts![index] = updatedAccount;
          }
        }

        debugPrint('✅ Account updated: ${updatedAccount.id}');
        return updatedAccount;
      }

      throw ServerException(
        'Failed to update account',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating account: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error updating account: $e');
    }
  }

  /// Delete an account
  /// DELETE /api/accounts/:id
  ///
  /// Deletes any account directly via API.
  /// No frontend restrictions - any account can be deleted.
  Future<void> deleteAccount(String accountId) async {
    try {
      if (accountId.isEmpty) {
        debugPrint('⚠️ Empty accountId - skipping delete');
        return;
      }

      debugPrint('🗑️ Deleting account: $accountId');

      // Call DELETE API directly - no restrictions
      final response = await _apiService.delete('/api/accounts/$accountId');

      debugPrint('📥 Delete response status: ${response.statusCode}');
      debugPrint('📥 Delete response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear cache to force reload
        clearCache();

        // Clear local default account preference if needed
        final defaultId = await getDefaultAccountId();
        if (defaultId == accountId) {
          await clearDefaultAccount();
        }

        debugPrint('✅ Account deleted successfully: $accountId');
        return;
      }

      throw ServerException(
        'Failed to delete account',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error deleting account: $e');
    }
  }

  /// Get a single account by ID
  Future<AccountModel?> getAccount(String accountId) async {
    try {
      if (accountId.isEmpty) {
        debugPrint('⚠️ Empty accountId - skipping fetch');
        return null;
      }

      // Try from cache first
      if (_cachedAccounts != null) {
        try {
          return _cachedAccounts!.firstWhere((a) => a.id == accountId);
        } catch (_) {
          // Not in cache, fetch from API
        }
      }

      final response = await _apiService.get('/api/accounts/$accountId');

      if (response.statusCode == 200) {
        return AccountModel.fromMap(
          response.data is Map
              ? response.data
              : response.data['account'] ?? response.data['data'],
        );
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching account: $e');
      return null;
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Get active accounts only
  Future<List<AccountModel>> getActiveAccounts() async {
    final accounts = await loadAccounts();
    return accounts.where((account) => account.isActive).toList();
  }

  /// Update account balance
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      if (accountId.isEmpty) {
        debugPrint('⚠️ Empty accountId - skipping balance update');
        return;
      }

      final account = await getAccount(accountId);
      if (account == null) {
        debugPrint('⚠️ Account not found: $accountId');
        return;
      }

      final updatedAccount = account.copyWith(balance: newBalance);
      await updateAccount(updatedAccount);

      debugPrint('✅ Account balance updated: $accountId -> $newBalance');
    } catch (e) {
      debugPrint('❌ Error updating account balance: $e');
    }
  }

  /// Add amount to account balance
  Future<void> addToAccountBalance(String accountId, double amount) async {
    if (accountId.isEmpty) {
      debugPrint('⚠️ Empty accountId - skipping add to balance');
      return;
    }

    final account = await getAccount(accountId);
    if (account != null) {
      final newBalance = account.balance + amount;
      debugPrint(
        '💰 Adding $amount to ${account.name}: ${account.balance} -> $newBalance',
      );
      await updateAccountBalance(accountId, newBalance);
    } else {
      debugPrint('❌ Account not found: $accountId');
    }
  }

  /// Subtract amount from account balance
  Future<void> subtractFromAccountBalance(
    String accountId,
    double amount,
  ) async {
    if (accountId.isEmpty) {
      debugPrint('⚠️ Empty accountId - skipping subtract from balance');
      return;
    }

    final account = await getAccount(accountId);
    if (account != null) {
      final newBalance = account.balance - amount;
      debugPrint(
        '💰 Subtracting $amount from ${account.name}: ${account.balance} -> $newBalance',
      );
      await updateAccountBalance(accountId, newBalance);
    } else {
      debugPrint('❌ Account not found: $accountId');
    }
  }

  /// Calculate total balance
  Future<double> getTotalBalance({bool includeInactiveAccounts = false}) async {
    final accounts = await loadAccounts();
    double total = 0.0;

    for (final account in accounts) {
      if (account.includeInTotal &&
          (includeInactiveAccounts || account.isActive)) {
        total += account.balance;
      }
    }

    return total;
  }

  /// Get balances by account type
  Future<Map<AccountType, double>> getBalancesByType() async {
    final accounts = await loadAccounts();
    final Map<AccountType, double> balances = {};

    for (final account in accounts) {
      if (account.isActive && account.includeInTotal) {
        balances[account.type] =
            (balances[account.type] ?? 0.0) + account.balance;
      }
    }

    return balances;
  }

  /// Get low balance accounts
  Future<List<AccountModel>> getLowBalanceAccounts() async {
    final accounts = await getActiveAccounts();
    return accounts.where((account) => account.isLowBalance).toList();
  }

  // ===========================================================================
  // DEFAULT ACCOUNT MANAGEMENT (Local Storage)
  // ===========================================================================

  /// Check if an ID is a valid MongoDB ObjectId format
  /// MongoDB ObjectIds are 24 hexadecimal characters (no hyphens)
  /// Returns false for UUIDs (which have hyphens) or other invalid formats
  bool _isValidMongoObjectId(String? id) {
    if (id == null || id.isEmpty) return false;
    // MongoDB ObjectId: exactly 24 hex characters, no hyphens
    // UUID format has hyphens, so this will reject UUIDs
    final mongoObjectIdPattern = RegExp(r'^[0-9a-fA-F]{24}$');
    return mongoObjectIdPattern.hasMatch(id);
  }

  /// Set default account (stored locally)
  Future<void> setDefaultAccount(String accountId) async {
    try {
      if (accountId.isEmpty) {
        debugPrint('⚠️ Empty accountId - skipping set default');
        return;
      }

      await _prefHelper.setString(_defaultAccountKey, accountId);
      debugPrint('✅ Default account set: $accountId');
    } catch (e) {
      debugPrint('❌ Error setting default account: $e');
    }
  }

  /// Get default account ID
  Future<String?> getDefaultAccountId() async {
    try {
      return await _prefHelper.getString(_defaultAccountKey);
    } catch (e) {
      debugPrint('❌ Error getting default account ID: $e');
      return null;
    }
  }

  /// Get default account
  Future<AccountModel?> getDefaultAccount() async {
    final defaultId = await getDefaultAccountId();
    if (defaultId != null) {
      // Validate ID format before making API call
      // Reject UUIDs and other invalid formats (MongoDB ObjectId is 24 hex chars)
      if (!_isValidMongoObjectId(defaultId)) {
        debugPrint(
          '⚠️ Invalid default account ID format (UUID or invalid): $defaultId - clearing invalid ID',
        );
        await clearDefaultAccount();
      } else {
        final account = await getAccount(defaultId);
        // If account not found (deleted account), clear the invalid ID
        if (account == null) {
          debugPrint(
            '⚠️ Default account ID not found: $defaultId - clearing invalid ID',
          );
          await clearDefaultAccount();
        } else {
          return account;
        }
      }
    }

    // If no default account or default account was invalid, select first active account
    final activeAccounts = await getActiveAccounts();
    if (activeAccounts.isNotEmpty) {
      await setDefaultAccount(activeAccounts.first.id);
      return activeAccounts.first;
    }

    return null;
  }

  /// Clear default account
  Future<void> clearDefaultAccount() async {
    try {
      await _prefHelper.remove(_defaultAccountKey);
      debugPrint('✅ Default account cleared');
    } catch (e) {
      debugPrint('❌ Error clearing default account: $e');
    }
  }

  // ===========================================================================
  // MONEY TRANSFER
  // ===========================================================================

  /// Transfer money between accounts
  Future<bool> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? notes,
  }) async {
    try {
      if (amount <= 0) return false;

      final fromAccount = await getAccount(fromAccountId);
      final toAccount = await getAccount(toAccountId);

      if (fromAccount == null || toAccount == null) return false;

      // Check sufficient balance (except for credit accounts)
      if (fromAccount.type != AccountType.credit &&
          fromAccount.balance < amount) {
        return false;
      }

      // Execute transfer
      await subtractFromAccountBalance(fromAccountId, amount);
      await addToAccountBalance(toAccountId, amount);

      debugPrint('✅ Transferred $amount from $fromAccountId to $toAccountId');
      return true;
    } catch (e) {
      debugPrint('❌ Error transferring money: $e');
      return false;
    }
  }

  // ===========================================================================
  // SEARCH AND STATISTICS
  // ===========================================================================

  /// Search accounts
  Future<List<AccountModel>> searchAccounts(String query) async {
    final accounts = await loadAccounts();

    if (query.isEmpty) return accounts;

    return accounts.where((account) {
      return account.name.toLowerCase().contains(query.toLowerCase()) ||
          account.type.displayName.contains(query) ||
          (account.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  /// Get account statistics
  Future<Map<String, dynamic>> getAccountStatistics() async {
    final accounts = await loadAccounts();
    final activeAccounts = accounts.where((a) => a.isActive).toList();

    return {
      'totalAccounts': accounts.length,
      'activeAccounts': activeAccounts.length,
      'totalBalance': await getTotalBalance(),
      'accountsByType': await getBalancesByType(),
      'lowBalanceAccounts': (await getLowBalanceAccounts()).length,
    };
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize and check for default accounts
  Future<void> initializeDefaultAccounts() async {
    try {
      final accounts = await loadAccounts();

      // Only set default account if accounts exist
      if (accounts.isNotEmpty) {
        final defaultId = await getDefaultAccountId();
        if (defaultId == null || await getAccount(defaultId) == null) {
          final activeAccounts = accounts.where((a) => a.isActive).toList();
          if (activeAccounts.isNotEmpty) {
            await setDefaultAccount(activeAccounts.first.id);
          }
        }
      }

      debugPrint(
        '✅ Account initialization complete: ${accounts.length} accounts',
      );
    } catch (e) {
      debugPrint('❌ Error initializing accounts: $e');
    }
  }

  /// Check if user has accounts
  Future<bool> hasAccounts() async {
    final accounts = await loadAccounts();
    return accounts.isNotEmpty;
  }
}
