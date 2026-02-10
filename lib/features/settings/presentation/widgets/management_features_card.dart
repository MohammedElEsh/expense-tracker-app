// Settings - Management Features Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/pages/recurring_expenses_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/accounts_screen.dart';
import 'package:expense_tracker/features/projects/presentation/pages/projects_screen.dart';
import 'package:expense_tracker/features/vendors/presentation/pages/vendors_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/user_management_screen.dart';
import 'package:expense_tracker/features/companies/presentation/pages/companies_screen.dart';
import 'package:expense_tracker/services/permission_service.dart';

class ManagementFeaturesCard extends StatelessWidget {
  final SettingsState settings;
  final User? currentUser;
  final bool isRTL;

  const ManagementFeaturesCard({
    super.key,
    required this.settings,
    required this.currentUser,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Recurring Expenses
        _buildManagementButton(
          context,
          title: isRTL ? 'المصروفات المتكررة' : 'Recurring Expenses',
          description:
              isRTL
                  ? 'إدارة المصروفات التي تتكرر تلقائياً (شهرياً، أسبوعياً، إلخ)'
                  : 'Manage expenses that recur automatically (monthly, weekly, etc)',
          icon: Icons.repeat,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecurringExpensesScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Accounts Management
        _buildManagementButton(
          context,
          title: isRTL ? 'إدارة الحسابات' : 'Account Management',
          description:
              isRTL
                  ? 'إدارة الحسابات البنكية والمحافظ الرقمية'
                  : 'Manage bank accounts and digital wallets',
          icon: Icons.account_balance,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountsScreen()),
            );
          },
        ),

        // Business Mode Only Features
        if (settings.isBusinessMode &&
            PermissionService.canManageExpenses(currentUser)) ...[
          const SizedBox(height: 16),

          // Company Management
          _buildManagementButton(
            context,
            title: isRTL ? 'إدارة الشركة' : 'Company Management',
            description:
                isRTL
                    ? 'إدارة معلومات الشركة والإعدادات الأساسية'
                    : 'Manage company information and basic settings',
            icon: Icons.business,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompaniesScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Projects Management
          _buildManagementButton(
            context,
            title: isRTL ? 'إدارة المشاريع' : 'Project Management',
            description:
                isRTL
                    ? 'قم بإدارة مشاريع الشركة وتتبع الميزانيات والمواعيد النهائية'
                    : 'Manage company projects and track budgets and deadlines',
            icon: Icons.work,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectsScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Vendors Management
          _buildManagementButton(
            context,
            title: isRTL ? 'إدارة الموردين' : 'Vendor Management',
            description:
                isRTL
                    ? 'إدارة قائمة الموردين والشركاء التجاريين'
                    : 'Manage vendors and business partners',
            icon: Icons.store,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VendorsScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // User Management (Owner can manage, Accountant can view)
          if (PermissionService.canViewUsers(currentUser)) ...[
            _buildManagementButton(
              context,
              title: isRTL ? 'إدارة المستخدمين' : 'User Management',
              description: PermissionService.canManageUsers(currentUser)
                  ? (isRTL
                      ? 'إدارة موظفي الشركة وصلاحياتهم'
                      : 'Manage company employees and their permissions')
                  : (isRTL
                      ? 'عرض قائمة موظفي الشركة'
                      : 'View company employees list'),
              icon: Icons.people,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildManagementButton(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: settings.secondaryTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: settings.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
