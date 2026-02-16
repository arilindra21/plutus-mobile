import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ApiExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ApiTransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Mobile Expense App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Lato',
          useMaterial3: true,
          colorSchemeSeed: PaperColor.blue,
          scaffoldBackgroundColor: PaperArtboardColor.surfaceDefault,
          appBarTheme: AppBarTheme(
            backgroundColor: PaperArtboardColor.surfaceVariant,
            foregroundColor: PaperTextColor.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: PaperIconColor.primary),
            titleTextStyle: PaperText.headingLarge.copyWith(
              color: PaperTextColor.primary,
              fontFamily: 'Lato',
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            dragHandleColor: PaperColor.grey30,
            dragHandleSize: Size(64, 6),
            surfaceTintColor: PaperColor.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ),
          cardTheme: CardThemeData(
            color: PaperArtboardColor.surfaceVariant,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: const BorderSide(color: PaperArtboardColor.border),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: PaperArtboardColor.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: PaperArtboardColor.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: PaperArtboardColor.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: PaperColor.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: PaperColor.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PaperSpacing.lg,
              vertical: PaperSpacing.md,
            ),
            hintStyle: PaperText.bodyRegular.copyWith(
              color: PaperTextColor.tertiary,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: PaperColor.blue,
              foregroundColor: PaperColor.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: PaperSpacing.xl,
                vertical: PaperSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: PaperText.headingRegular.copyWith(
                fontFamily: 'Lato',
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: PaperColor.blue,
              side: const BorderSide(color: PaperColor.blue),
              padding: const EdgeInsets.symmetric(
                horizontal: PaperSpacing.xl,
                vertical: PaperSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: PaperText.headingRegular.copyWith(
                fontFamily: 'Lato',
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: PaperColor.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: PaperSpacing.lg,
                vertical: PaperSpacing.sm,
              ),
              textStyle: PaperText.headingRegular.copyWith(
                fontFamily: 'Lato',
              ),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: PaperArtboardColor.divider,
            thickness: 1,
            space: 0,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: PaperColor.blue10,
            labelStyle: PaperText.bodySmall.copyWith(
              color: PaperColor.blue,
              fontFamily: 'Lato',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            side: BorderSide.none,
          ),
        ),
        home: const AppRouter(),
      ),
    );
  }
}

/// App Router - handles screen navigation with side menu overlay
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  void _checkAuthState() {
    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<AppProvider>();

    // If already authenticated, update AppProvider
    if (authProvider.isAuthenticated && authProvider.user != null) {
      appProvider.loginWithApi(authProvider.user!);
    }
    setState(() => _initialized = true);

    // Also listen for future changes
    authProvider.addListener(_onAuthStateChange);
  }

  void _onAuthStateChange() {
    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<AppProvider>();

    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Only update if not already on a valid screen
      if (appProvider.currentScreen == 'login') {
        appProvider.loginWithApi(authProvider.user!);
      }
    } else if (authProvider.status == AuthStatus.unauthenticated) {
      appProvider.logout();
    }
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    try {
      context.read<AuthProvider>().removeListener(_onAuthStateChange);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, AuthProvider>(
      builder: (context, appProvider, authProvider, _) {
        // Show loading while initializing auth
        if (!_initialized && authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Stack(
          children: [
            // Main screen content
            _buildScreen(appProvider.currentScreen),

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

  Widget _buildScreen(String screen) {
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
      top: MediaQuery.of(context).padding.top + PaperSpacing.lg,
      left: PaperSpacing.lg,
      right: PaperSpacing.lg,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(PaperSpacing.md),
          decoration: BoxDecoration(
            color: isSuccess
                ? PaperColor.semanticGreen
                : isError
                    ? PaperColor.red
                    : PaperColor.blue,
            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                color: PaperColor.white,
                size: 20,
              ),
              const SizedBox(width: PaperSpacing.sm),
              Expanded(
                child: Text(
                  notification['message'] ?? '',
                  style: PaperText.bodyRegular.white,
                ),
              ),
              GestureDetector(
                onTap: () => appProvider.hideNotification(),
                child: const Icon(
                  Icons.close,
                  color: PaperColor.white,
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
