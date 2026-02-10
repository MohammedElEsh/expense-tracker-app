import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';

class EmptyStateWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionText;
  final VoidCallback? onAction;
  final Color? primaryColor;
  final bool useAnimation;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionText,
    this.onAction,
    this.primaryColor,
    this.useAnimation = true,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.useAnimation) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
        ),
      );

      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
        ),
      );

      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.useAnimation) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? Theme.of(context).primaryColor;

    Widget content = SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 2000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.7 + (0.3 * value),
                  child: Icon(
                    widget.icon,
                    size: 50,
                    color: color.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Action button
          if (widget.onAction != null)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: ElevatedButton.icon(
                    onPressed: widget.onAction,
                    icon: Icon(Icons.add, size: 20),
                    label: Text(
                      widget.actionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 4,
                      shadowColor: color.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    if (!widget.useAnimation) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: content),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: content),
          ),
        ),
      ),
    );
  }
}

// Predefined empty states for common scenarios
class ExpenseEmptyState extends StatelessWidget {
  final VoidCallback? onAddExpense;
  final bool isRTL;

  const ExpenseEmptyState({super.key, this.onAddExpense, this.isRTL = false});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: isRTL ? 'لا توجد مصروفات بعد' : 'No expenses yet',
      subtitle:
          isRTL
              ? 'ابدأ بإضافة أول مصروف لك لتتبع إنفاقك اليومي والحصول على تحليلات مفيدة'
              : 'Start by adding your first expense to track your daily spending and get helpful insights',
      actionText: isRTL ? 'إضافة مصروف' : 'Add Expense',
      onAction: onAddExpense,
      primaryColor: Colors.blue,
    );
  }
}

class BudgetEmptyState extends StatelessWidget {
  final VoidCallback? onAddBudget;
  final bool isRTL;

  const BudgetEmptyState({super.key, this.onAddBudget, this.isRTL = false});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.savings_outlined,
      title: isRTL ? 'لم يتم تعيين ميزانيات' : 'No budgets set',
      subtitle:
          isRTL
              ? 'قم بتعيين ميزانيات شهرية لكل فئة للتحكم في إنفاقك بشكل أفضل'
              : 'Set monthly budgets for each category to better control your spending',
      actionText: isRTL ? 'إضافة ميزانية' : 'Add Budget',
      onAction: onAddBudget,
      primaryColor: Colors.green,
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final bool isRTL;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: isRTL ? 'لم يتم العثور على نتائج' : 'No results found',
      subtitle:
          isRTL
              ? 'لم نتمكن من العثور على مصروفات تطابق "$searchQuery". جرب مصطلحات بحث مختلفة.'
              : 'We couldn\'t find any expenses matching "$searchQuery". Try different search terms.',
      actionText: isRTL ? 'مسح البحث' : 'Clear Search',
      onAction: null,
      primaryColor: Colors.orange,
      useAnimation: false,
    );
  }
}
