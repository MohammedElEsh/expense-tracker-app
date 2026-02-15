import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_notification_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_remote_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_reminder_preferences_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart' as model;
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurrence_type.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseRemoteDataSource _remote;
  final RecurringExpenseNotificationDataSource _notification;
  final RecurringReminderPreferencesDataSource _reminderPrefs;

  RecurringExpenseRepositoryImpl({
    required RecurringExpenseRemoteDataSource remote,
    required RecurringExpenseNotificationDataSource notification,
    required RecurringReminderPreferencesDataSource reminderPrefs,
  })  : _remote = remote,
        _notification = notification,
        _reminderPrefs = reminderPrefs;

  @override
  void clearCache() => _remote.clearCache();

  @override
  Future<List<RecurringExpenseEntity>> getRecurringExpenses({
    bool forceRefresh = false,
  }) async {
    final models = await _remote.getRecurringExpenses(forceRefresh: forceRefresh);
    await _notification.rescheduleAll(models);
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<RecurringExpenseEntity> createRecurringExpense(
    RecurringExpenseEntity entity,
  ) async {
    final m = _entityToModel(entity);
    final created = await _remote.createRecurringExpense(m);
    if (created.isActive) {
      await _notification.scheduleReminder(created);
    }
    return _modelToEntity(created);
  }

  @override
  Future<RecurringExpenseEntity> updateRecurringExpense(
    RecurringExpenseEntity entity,
  ) async {
    final m = _entityToModel(entity);
    final updated = await _remote.updateRecurringExpense(m);
    if (updated.isActive) {
      await _notification.scheduleReminder(updated);
    } else {
      await _notification.cancelReminder(updated.id);
    }
    return _modelToEntity(updated);
  }

  @override
  Future<void> deleteRecurringExpense(String id) async {
    await _remote.deleteRecurringExpense(id);
    await _notification.cancelReminder(id);
  }

  @override
  Future<void> enableReminder(String id) async {
    final m = await _remote.getRecurringExpenseById(id);
    if (m != null && m.isActive) {
      await _notification.scheduleReminder(m);
    }
  }

  @override
  Future<void> disableReminder(String id) async {
    await _notification.cancelReminder(id);
  }

  @override
  Future<bool> getRemindersEnabled() => _reminderPrefs.getRemindersEnabled();

  @override
  Future<void> setRemindersEnabled(bool enabled) async {
    await _reminderPrefs.setRemindersEnabled(enabled);
    final models = await _remote.getRecurringExpenses(forceRefresh: false);
    await _notification.rescheduleAll(enabled ? models : []);
  }

  @override
  Future<void> rescheduleAllReminders() async {
    final models = await _remote.getRecurringExpenses(forceRefresh: true);
    await _notification.rescheduleAll(models);
  }

  @override
  Future<void> showTestReminderNotification() async {
    await _notification.showTestNotification();
  }

  RecurringExpenseEntity _modelToEntity(model.RecurringExpense m) {
    return RecurringExpenseEntity(
      id: m.id,
      accountId: m.accountId,
      accountName: m.accountName,
      amount: m.amount,
      category: m.category,
      notes: m.notes,
      recurrenceType: _domainRecurrence(m.recurrenceType),
      dayOfMonth: m.dayOfMonth,
      dayOfWeek: m.dayOfWeek,
      isActive: m.isActive,
      createdAt: m.createdAt,
      lastProcessed: m.lastProcessed,
      nextDue: m.nextDue,
      appMode: m.appMode.name,
    );
  }

  model.RecurringExpense _entityToModel(RecurringExpenseEntity e) {
    return model.RecurringExpense(
      id: e.id,
      accountId: e.accountId,
      accountName: e.accountName,
      amount: e.amount,
      category: e.category,
      notes: e.notes,
      recurrenceType: _modelRecurrence(e.recurrenceType),
      dayOfMonth: e.dayOfMonth,
      dayOfWeek: e.dayOfWeek,
      appMode: _modelAppMode(e.appMode),
      isActive: e.isActive,
      createdAt: e.createdAt,
      lastProcessed: e.lastProcessed,
      nextDue: e.nextDue,
    );
  }

  RecurrenceType _domainRecurrence(model.RecurrenceType r) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name == r.name,
      orElse: () => RecurrenceType.monthly,
    );
  }

  model.RecurrenceType _modelRecurrence(RecurrenceType r) {
    return model.RecurrenceType.values.firstWhere(
      (e) => e.name == r.name,
      orElse: () => model.RecurrenceType.monthly,
    );
  }

  AppMode _modelAppMode(String s) {
    return AppMode.values.firstWhere(
      (e) => e.name == s,
      orElse: () => AppMode.personal,
    );
  }
}
