import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/design_tokens.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/api_expense_provider.dart';
import 'providers/api_transaction_provider.dart';

// Auth screens
import 'screens/auth/api_login_screen.dart';

// Main screens
import 'screens/home/home_screen.dart';
import 'screens/expenses/transactions_screen.dart';
import 'screens/expenses/transaction_detail_screen.dart';
import 'screens/expenses/new_expense_screen.dart';
import 'screens/expenses/expense_created_screen.dart';
import 'screens/expenses/card_transactions_screen.dart';

// Budget screens
import 'screens/budget/budget_overview_screen.dart';
import 'screens/budget/budget_category_detail_screen.dart';

// Cards screens
import 'screens/cards/cards_screen.dart';
import 'screens/cards/card_detail_screen.dart';

// Notifications
import 'screens/notifications/notifications_screen.dart';

// Camera
import 'screens/camera/camera_screen.dart';

// History
import 'screens/history/history_log_screen.dart';

// Approver screens
import 'screens/approver/review_approve_screen.dart';
import 'screens/approver/approver_expense_detail_screen.dart';
import 'screens/approver/approval_success_screen.dart';

// Layout widgets
import 'widgets/layout/side_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Navigation and UI state
        ChangeNotifierProvider(create: (_) => AppProvider()),

        // Authentication (API-backed)
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),

        // Expense data (API-backed)
        ChangeNotifierProvider(create: (_) => ApiExpenseProvider()),

        // Transaction data (API-backed for card transactions)
        ChangeNotifierProvider(create: (_) => ApiTransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Mobile Expense App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.success,
            error: AppColors.danger,
            surface: AppColors.bgDefault,
          ),
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: AppColors.bgPaper,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.bgDefault,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
        ),
        home: const AppRouter(),
      ),
    );
  }
}

/// App Router - handles screen navigation with side menu overlay
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, AuthProvider>(
      builder: (context, appProvider, authProvider, _) {
        return Stack(
          children: [
            // Main screen content
            _buildScreen(appProvider.currentScreen, authProvider),

            // Side menu overlay
            if (appProvider.sideMenuOpen)
              GestureDetector(
                onTap: () => appProvider.toggleSideMenu(),
                child: Container(
                  color: Colors.black54,
                ),
              ),

            // Side menu
            const SideMenu(),

            // Notification toast
            if (appProvider.notification != null)
              _buildNotificationToast(context, appProvider),
          ],
        );
      },
    );
  }

  Widget _buildScreen(String screen, AuthProvider authProvider) {
    switch (screen) {
      // Auth
      case 'login':
        return const ApiLoginScreen();

      // Main tabs
      case 'home':
      case 'approverHome':
        return const HomeScreen();

      case 'transactions':
      case 'expenses':
        return const TransactionsScreen();

      case 'notifications':
        return const NotificationsScreen();

      // Expense flow
      case 'transactionDetail':
        return const TransactionDetailScreen();

      case 'cardTransactions':
        return const CardTransactionsScreen();

      case 'newExpense':
        return const NewExpenseScreen();

      case 'expenseCreated':
        return const ExpenseCreatedScreen();

      // Budget
      case 'budget':
      case 'budgetOverview':
        return const BudgetOverviewScreen();

      case 'budgetCategoryDetail':
        return const BudgetCategoryDetailScreen();

      // Cards
      case 'cards':
        return const CardsScreen();

      case 'cardDetail':
        return const CardDetailScreen();

      // Camera
      case 'camera':
        return const CameraScreen();

      // History
      case 'historyLog':
      case 'history':
        return const HistoryLogScreen();

      // Approver screens
      case 'reviewApprove':
        return const ReviewApproveScreen();

      case 'approverExpenseDetail':
        return const ApproverExpenseDetailScreen();

      case 'approvalSuccess':
        return const ApprovalSuccessScreen();

      default:
        return const HomeScreen();
    }
  }

  Widget _buildNotificationToast(BuildContext context, AppProvider appProvider) {
    final notification = appProvider.notification!;
    final isSuccess = notification['type'] == 'success';
    final isError = notification['type'] == 'error';

    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSuccess
                ? AppColors.success
                : isError
                    ? AppColors.danger
                    : AppColors.info,
            borderRadius: AppRadius.borderRadiusLg,
            boxShadow: AppShadows.lg,
          ),
          child: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle
                    : isError
                        ? Icons.error
                        : Icons.info,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  notification['message'] ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => appProvider.hideNotification(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
