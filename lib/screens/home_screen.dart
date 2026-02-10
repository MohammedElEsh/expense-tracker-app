import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_event.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_event.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_item.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/search_filter_widget.dart';
import '../widgets/simple_add_fab.dart';
import '../widgets/animated_page_route.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import '../utils/responsive_utils.dart';
import '../utils/theme_helper.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/accounts_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  List<Expense> filteredExpenses = [];
  bool isSearchVisible = false;
  String viewMode =
      'all'; // 'day', 'week', 'month', 'all' - تغيير لـ all علشان يظهر كل المصروفات
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // تسجيل الخروج
  Future<void> _handleLogout() async {
    final settings = context.read<SettingsBloc>().state;
    final isRTL = settings.language == 'ar';

    // عرض dialog التأكيد
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من تسجيل الخروج؟'
                  : 'Are you sure you want to logout?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: settings.errorColor,
                  foregroundColor:
                      settings.isDarkMode ? Colors.black : Colors.white,
                ),
                child: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
              ),
            ],
          ),
    );

    // إذا تم التأكيد
    if (confirmed == true && mounted) {
      try {
        // تسجيل الخروج عبر REST API
        await serviceLocator.authRemoteDataSource.logout();

        // مسح البيانات المحلية
        await SettingsService.clearModeAndCompany();

        if (mounted) {
          // تسجيل الخروج من BLoC
          context.read<UserBloc>().add(const LogoutUser());

          // الانتقال لشاشة تسجيل الدخول مباشرة
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SimpleLoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('❌ خطأ في تسجيل الخروج: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL ? 'خطأ في تسجيل الخروج: $e' : 'Error logging out: $e',
              ),
              backgroundColor: settings.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, expenseState) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final displayExpenses = _getDisplayExpenses(expenseState);
                final totalAmount = _getTotalAmount(expenseState);
                final transactionCount = displayExpenses.length;
                final isRTL = settings.language == 'ar';
                final isTablet = MediaQuery.of(context).size.width > 600;
                final isDesktop = context.isDesktop;
                final currentUser = userState.currentUser;

                // Debug prints
                debugPrint(
                  '🏠 HomeScreen - إجمالي المصروفات: ${expenseState.allExpenses.length}',
                );
                debugPrint(
                  '🏠 HomeScreen - المصروفات المعروضة: ${displayExpenses.length}',
                );
                debugPrint('🏠 HomeScreen - الوضع: $viewMode');
                debugPrint('🏠 HomeScreen - المبلغ الإجمالي: $totalAmount');

                // Use filtered expenses if search is active, otherwise use calculated expenses
                final finalDisplayExpenses =
                    isSearchVisible ? filteredExpenses : displayExpenses;

                return Directionality(
                  textDirection:
                      isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(
                        isDesktop ? 72 : (isTablet ? 68 : kToolbarHeight),
                      ),
                      child: Directionality(
                        textDirection:
                            ui.TextDirection.ltr, // ⭐ فرض LTR دائماً للـ AppBar
                        child: AppBar(
                          automaticallyImplyLeading:
                              false, // ⭐ منع السهم التلقائي
                          leading:
                              isDesktop
                                  ? null
                                  : IconButton(
                                    icon: const Icon(Icons.logout),
                                    tooltip: isRTL ? 'تسجيل الخروج' : 'Logout',
                                    onPressed: _handleLogout,
                                  ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // العنوان على اليسار - مرن
                              Flexible(
                                child: Text(
                                  isRTL ? 'متتبع المصروفات' : 'Expense Tracker',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        isDesktop ? 22 : (isTablet ? 20 : 16),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: isDesktop ? 16 : 8),
                              // User info على اليمين - مضغوط
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // App Mode Icon
                                  Container(
                                    width: isDesktop ? 32 : 28,
                                    height: isDesktop ? 32 : 28,
                                    decoration: BoxDecoration(
                                      color:
                                          settings.appMode == AppMode.personal
                                              ? Colors.green.withValues(
                                                alpha: 0.2,
                                              )
                                              : Colors.blue.withValues(
                                                alpha: 0.2,
                                              ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      settings.appMode == AppMode.personal
                                          ? Icons.person
                                          : Icons.business,
                                      color:
                                          settings.appMode == AppMode.personal
                                              ? Colors.green
                                              : Colors.blue,
                                      size: isDesktop ? 18 : 16,
                                    ),
                                  ),
                                  SizedBox(width: isDesktop ? 10 : 6),
                                  // App Mode and User Info
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          settings.appMode == AppMode.personal
                                              ? (isRTL ? 'شخصي' : 'Personal')
                                              : (isRTL ? 'تجاري' : 'Business'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isDesktop ? 14 : 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (settings.appMode ==
                                                AppMode.business &&
                                            currentUser != null)
                                          Text(
                                            currentUser.name,
                                            style: TextStyle(
                                              color: currentUser.role.color,
                                              fontWeight: FontWeight.w500,
                                              fontSize: isDesktop ? 12 : 10,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: isDesktop ? 16 : 8),
                                ],
                              ),
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          actions: [
                            IconButton(
                              icon: Icon(
                                isSearchVisible
                                    ? Icons.search_off
                                    : Icons.search,
                                size: isDesktop ? 26 : (isTablet ? 28 : 24),
                              ),
                              onPressed: () {
                                setState(() {
                                  isSearchVisible = !isSearchVisible;
                                  if (!isSearchVisible) {
                                    filteredExpenses = [];
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                size: isDesktop ? 26 : (isTablet ? 28 : 24),
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                            if (isDesktop)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isRTL ? 'تسجيل الخروج' : 'Logout',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onPressed: _handleLogout,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    body: Column(
                      children: [
                        // Search and Filter Widget
                        if (isSearchVisible)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: SearchFilterWidget(
                                expenses: expenseState.allExpenses,
                                onFilteredExpenses: (filtered) {
                                  setState(() {
                                    filteredExpenses = filtered;
                                  });
                                },
                                isRTL: isRTL,
                              ),
                            ),
                          ),

                        // Date and Summary Card (only show when not searching)
                        if (!isSearchVisible)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.all(
                                  isDesktop ? 32 : (isTablet ? 24 : 16),
                                ),
                                padding: EdgeInsets.all(
                                  isDesktop ? 40 : (isTablet ? 32 : 20),
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        settings.isDarkMode
                                            ? [
                                              const Color(0xFF1976D2),
                                              const Color(0xFF1565C0),
                                            ]
                                            : [Colors.blue, Colors.blueAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    context.borderRadius,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: settings.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: isDesktop ? 12 : 8,
                                      offset: Offset(0, isDesktop ? 6 : 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _getViewModeTitle(isRTL),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                isDesktop
                                                    ? 24
                                                    : (isTablet ? 20 : 16),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:
                                              () => _showViewModeSelector(
                                                context,
                                                isRTL,
                                              ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  isDesktop
                                                      ? 16
                                                      : (isTablet ? 12 : 8),
                                              vertical:
                                                  isDesktop
                                                      ? 10
                                                      : (isTablet ? 8 : 4),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    context.borderRadius,
                                                  ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                  size:
                                                      isDesktop
                                                          ? 26
                                                          : (isTablet
                                                              ? 24
                                                              : 20),
                                                ),
                                                Text(
                                                  _getViewModeLabel(isRTL),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        isTablet ? 16 : 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${settings.currencySymbol}${totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isRTL
                                          ? '$transactionCount معاملة'
                                          : '$transactionCount transactions',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Expenses List
                        Expanded(
                          child:
                              finalDisplayExpenses.isEmpty
                                  ? FadeTransition(
                                    opacity: _fadeAnimation,
                                    child:
                                        isSearchVisible
                                            ? SearchEmptyState(
                                              searchQuery: "search terms",
                                              isRTL: isRTL,
                                            )
                                            : ExpenseEmptyState(
                                              onAddExpense:
                                                  () => _showAddExpenseDialog(
                                                    context,
                                                  ),
                                              isRTL: isRTL,
                                            ),
                                  )
                                  : FadeTransition(
                                    opacity: _fadeAnimation,
                                    child:
                                        isDesktop
                                            ? _buildDesktopExpensesGrid(
                                              finalDisplayExpenses,
                                              settings,
                                              isRTL,
                                            )
                                            : ListView.builder(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isTablet ? 24 : 16,
                                              ),
                                              itemCount:
                                                  finalDisplayExpenses.length,
                                              itemBuilder: (context, index) {
                                                final expense =
                                                    finalDisplayExpenses[index];
                                                return TweenAnimationBuilder<
                                                  double
                                                >(
                                                  duration: Duration(
                                                    milliseconds:
                                                        400 + (index * 100),
                                                  ),
                                                  tween: Tween(
                                                    begin: 0.0,
                                                    end: 1.0,
                                                  ),
                                                  builder: (
                                                    context,
                                                    value,
                                                    child,
                                                  ) {
                                                    return Transform.translate(
                                                      offset: Offset(
                                                        0,
                                                        20 * (1 - value),
                                                      ),
                                                      child: Opacity(
                                                        opacity: value,
                                                        child: ExpenseItem(
                                                          expense: expense,
                                                          currencySymbol:
                                                              settings
                                                                  .currencySymbol,
                                                          isRTL: isRTL,
                                                          onDelete: () {
                                                            context
                                                                .read<
                                                                  ExpenseBloc
                                                                >()
                                                                .add(
                                                                  DeleteExpense(
                                                                    expense.id,
                                                                  ),
                                                                );
                                                            context
                                                                .read<
                                                                  AccountBloc
                                                                >()
                                                                .add(
                                                                  const LoadAccounts(),
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                  ),
                        ),

                        // Ad space placeholder
                        Container(
                          height: isDesktop ? 100 : (isTablet ? 80 : 60),
                          margin: EdgeInsets.all(
                            isDesktop ? 32 : (isTablet ? 24 : 16),
                          ),
                          decoration: BoxDecoration(
                            color: context.backgroundCardColor,
                            borderRadius: BorderRadius.circular(
                              isDesktop ? 16 : (isTablet ? 12 : 8),
                            ),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Center(
                            child: Text(
                              isRTL ? 'مساحة إعلانية' : 'Ad Space',
                              style: TextStyle(
                                color: context.secondaryTextColor,
                                fontSize: isDesktop ? 20 : (isTablet ? 18 : 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: SimpleAddFAB(
                      selectedDate: selectedDate,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    final settings = context.read<SettingsBloc>().state;
    final isRTL = settings.language == 'ar';

    // فحص وجود حسابات أولاً
    final accountState = context.read<AccountBloc>().state;

    if (accountState.accounts.isEmpty) {
      // عرض Dialog تحذيري
      final result = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isRTL ? 'لا توجد حسابات بنكية!' : 'No Bank Accounts!',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
              content: Text(
                isRTL
                    ? 'يجب إضافة حساب بنكي واحد على الأقل قبل إضافة المصروفات.\n\nهل تريد إضافة حساب الآن؟'
                    : 'You must add at least one bank account before adding expenses.\n\nDo you want to add an account now?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.add),
                  label: Text(isRTL ? 'إضافة حساب' : 'Add Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: settings.primaryColor,
                    foregroundColor:
                        settings.isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
      );

      // إذا وافق المستخدم، انتقل لشاشة الحسابات
      if (result == true && mounted) {
        // استيراد الصفحة مطلوب في الأعلى
        Navigator.of(
          // ignore: use_build_context_synchronously
          context,
        ).push(MaterialPageRoute(builder: (context) => const AccountsScreen()));
      }
      return;
    }

    // إذا يوجد حسابات، افتح Dialog الإضافة
    Navigator.of(context).pushWithAnimation(
      AddExpenseDialog(selectedDate: selectedDate),
      animationType: AnimationType.slideUp,
    );
  }

  // Helper methods for view mode functionality
  List<Expense> _getDisplayExpenses(ExpenseState expenseState) {
    switch (viewMode) {
      case 'day':
        return expenseState.getExpensesForDate(selectedDate);
      case 'week':
        return _getExpensesForWeek(expenseState);
      case 'month':
        return expenseState.getExpensesForMonth(
          selectedDate.year,
          selectedDate.month,
        );
      case 'all':
        return expenseState.allExpenses; // عرض جميع المصروفات
      default:
        return expenseState.allExpenses; // الافتراضي: جميع المصروفات
    }
  }

  double _getTotalAmount(ExpenseState expenseState) {
    switch (viewMode) {
      case 'day':
        return expenseState.getTotalForDate(selectedDate);
      case 'week':
        return _getTotalForWeek(expenseState);
      case 'month':
        return _getTotalForMonth(expenseState);
      case 'all':
        return expenseState.totalExpenses; // إجمالي جميع المصروفات
      default:
        return expenseState.totalExpenses; // الافتراضي: إجمالي جميع المصروفات
    }
  }

  List<Expense> _getExpensesForWeek(ExpenseState expenseState) {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    return expenseState.allExpenses.where((expense) {
      return expense.date.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  double _getTotalForWeek(ExpenseState expenseState) {
    final weekExpenses = _getExpensesForWeek(expenseState);
    return weekExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _getTotalForMonth(ExpenseState expenseState) {
    final monthExpenses = expenseState.getExpensesForMonth(
      selectedDate.year,
      selectedDate.month,
    );
    return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  String _getViewModeTitle(bool isRTL) {
    switch (viewMode) {
      case 'day':
        return isRTL
            ? 'اليوم: ${DateFormat('dd MMMM yyyy', 'ar').format(selectedDate)}'
            : 'Today: ${DateFormat('MMM dd, yyyy').format(selectedDate)}';
      case 'week':
        final weekStart = selectedDate.subtract(
          Duration(days: selectedDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return isRTL
            ? 'الأسبوع: ${DateFormat('dd MMM', 'ar').format(weekStart)} - ${DateFormat('dd MMM', 'ar').format(weekEnd)}'
            : 'Week: ${DateFormat('MMM dd').format(weekStart)} - ${DateFormat('MMM dd').format(weekEnd)}';
      case 'month':
        return isRTL
            ? 'الشهر: ${DateFormat('MMMM yyyy', 'ar').format(selectedDate)}'
            : 'Month: ${DateFormat('MMMM yyyy').format(selectedDate)}';
      case 'all':
        return isRTL ? 'جميع المصروفات' : 'All Expenses';
      default:
        return isRTL ? 'جميع المصروفات' : 'All Expenses';
    }
  }

  String _getViewModeLabel(bool isRTL) {
    switch (viewMode) {
      case 'day':
        return isRTL ? 'اليوم' : 'Day';
      case 'week':
        return isRTL ? 'الأسبوع' : 'Week';
      case 'month':
        return isRTL ? 'الشهر' : 'Month';
      case 'all':
        return isRTL ? 'الكل' : 'All';
      default:
        return isRTL ? 'الكل' : 'All';
    }
  }

  void _showViewModeSelector(BuildContext context, bool isRTL) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isRTL ? 'اختر طريقة العرض' : 'Select View Mode',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildViewModeOption(
                  context,
                  'all',
                  isRTL ? 'الكل' : 'All',
                  isRTL,
                ),
                _buildViewModeOption(
                  context,
                  'day',
                  isRTL ? 'اليوم' : 'Day',
                  isRTL,
                ),
                _buildViewModeOption(
                  context,
                  'week',
                  isRTL ? 'الأسبوع' : 'Week',
                  isRTL,
                ),
                _buildViewModeOption(
                  context,
                  'month',
                  isRTL ? 'الشهر' : 'Month',
                  isRTL,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildViewModeOption(
    BuildContext context,
    String mode,
    String label,
    bool isRTL,
  ) {
    final isSelected = viewMode == mode;
    return ListTile(
      leading: Icon(
        mode == 'day'
            ? Icons.today
            : mode == 'week'
            ? Icons.view_week
            : Icons.calendar_month,
        color: isSelected ? context.primaryColor : context.iconColor,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? context.primaryColor : context.primaryTextColor,
        ),
      ),
      trailing:
          isSelected ? Icon(Icons.check, color: context.primaryColor) : null,
      onTap: () {
        setState(() {
          viewMode = mode;
        });
        Navigator.pop(context);
      },
    );
  }

  /// بناء شبكة المصروفات لسطح المكتب
  Widget _buildDesktopExpensesGrid(
    List<Expense> expenses,
    SettingsState settings,
    bool isRTL,
  ) {
    // تحديد عدد الأعمدة حسب عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 1600) {
      crossAxisCount = 4; // شاشات كبيرة جداً
      childAspectRatio = 3.2;
    } else if (screenWidth > 1200) {
      crossAxisCount = 3; // شاشات كبيرة
      childAspectRatio = 3.0;
    } else {
      crossAxisCount = 2; // شاشات متوسطة
      childAspectRatio = 2.8;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 12,
        ),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 30)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildDesktopExpenseCard(expense, settings, isRTL),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// بناء كارت المصروف لسطح المكتب
  Widget _buildDesktopExpenseCard(
    Expense expense,
    SettingsState settings,
    bool isRTL,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settings.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: settings.primaryColor.withValues(alpha: 0.08),
          splashColor: settings.primaryColor.withValues(alpha: 0.12),
          onTap: () {
            Navigator.push(
              context,
              AnimatedPageRoute(child: ExpenseDetailsScreen(expense: expense)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with amount and delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${expense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: settings.primaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          () => _showDeleteConfirmationDialog(
                            expense,
                            settings,
                            isRTL,
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  expense.notes,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: settings.primaryTextColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Category and date
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      expense.category,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(expense.category),
                        size: 12,
                        color: _getCategoryColor(expense.category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expense.getDisplayCategoryName(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getCategoryColor(expense.category),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  DateFormat('dd MMM yyyy • HH:mm', isRTL ? 'ar' : 'en').format(expense.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: context.tertiaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// الحصول على لون الفئة
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'طعام':
      case 'food':
        return Colors.orange;
      case 'مواصلات':
      case 'transport':
        return Colors.blue;
      case 'تسوق':
      case 'shopping':
        return Colors.purple;
      case 'ترفيه':
      case 'entertainment':
        return Colors.pink;
      case 'صحة':
      case 'health':
        return Colors.green;
      case 'تعليم':
      case 'education':
        return Colors.indigo;
      case 'سفر':
      case 'travel':
        return Colors.teal;
      case 'رواتب الموظفين':
      case 'employee salaries':
        return Colors.red;
      case 'مصاريف سفر بعض الاعضاء':
      case 'travel expenses for some members':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على أيقونة الفئة
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'طعام':
      case 'food':
        return Icons.restaurant;
      case 'مواصلات':
      case 'transport':
        return Icons.directions_car;
      case 'تسوق':
      case 'shopping':
        return Icons.shopping_bag;
      case 'ترفيه':
      case 'entertainment':
        return Icons.movie;
      case 'صحة':
      case 'health':
        return Icons.medical_services;
      case 'تعليم':
      case 'education':
        return Icons.school;
      case 'سفر':
      case 'travel':
        return Icons.flight;
      case 'رواتب الموظفين':
      case 'employee salaries':
        return Icons.people;
      case 'مصاريف سفر بعض الاعضاء':
      case 'travel expenses for some members':
        return Icons.business_center;
      default:
        return Icons.category;
    }
  }

  /// عرض dialog تأكيد الحذف
  void _showDeleteConfirmationDialog(
    Expense expense,
    SettingsState settings,
    bool isRTL,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: settings.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRTL ? 'تأكيد الحذف' : 'Confirm Delete',
                  style: TextStyle(
                    color: settings.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRTL
                    ? 'هل أنت متأكد من حذف هذا المصروف؟'
                    : 'Are you sure you want to delete this expense?',
                style: TextStyle(
                  color: settings.primaryTextColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: settings.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: settings.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${expense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
                      style: TextStyle(
                        color: settings.primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (expense.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expense.notes,
                        style: TextStyle(
                          color: settings.secondaryTextColor,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRTL
                    ? 'لا يمكن التراجع عن هذا الإجراء.'
                    : 'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: settings.secondaryTextColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
                context.read<AccountBloc>().add(const LoadAccounts());

                // عرض رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRTL
                          ? 'تم حذف المصروف بنجاح'
                          : 'Expense deleted successfully',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'حذف' : 'Delete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
