import 'package:flutter/material.dart';
import 'data/services/database_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/security_service.dart';
import 'domain/models/transaction_item.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/curved_glass_nav_bar.dart';
import 'ui/core/liquid_motion_background.dart';
import 'ui/core/theme_controller.dart';
import 'ui/features/analytics/view_models/analytics_view_model.dart';
import 'ui/features/analytics/views/analytics_view.dart';
import 'ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'ui/features/dashboard/views/dashboard_view.dart';
import 'ui/features/security/views/pin_screen.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';
import 'ui/features/settings/views/settings_view.dart';
import 'package:flutter/services.dart';
import 'ui/features/transactions/view_models/transaction_view_model.dart';
import 'ui/features/transactions/views/add_edit_transaction_view.dart';
import 'ui/features/transactions/views/transaction_list_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default system status bar style (transparent)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize background services and persistent theme
  await NotificationService().init();
  await DatabaseService().database;
  await ThemeController().init();

  runApp(const JodTangApp());
}

class JodTangApp extends StatefulWidget {
  const JodTangApp({super.key});

  @override
  State<JodTangApp> createState() => _JodTangAppState();
}

class _JodTangAppState extends State<JodTangApp> with WidgetsBindingObserver {
  final SecurityService _securityService = SecurityService();
  bool _isLocked = true;
  bool _hasCheckedLock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkInitialLock() async {
    final pinEnabled = await _securityService.isPinEnabled();
    if (mounted) {
      setState(() {
        _isLocked = pinEnabled;
        _hasCheckedLock = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _checkReLock();
    }
  }

  Future<void> _checkReLock() async {
    final pinEnabled = await _securityService.isPinEnabled();
    if (pinEnabled && mounted) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  void _onUnlocked() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController(),
      builder: (context, _) {
        return MaterialApp(
          title: 'จดตัง (Jod Tang)',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController().themeMode,
          builder: (context, child) {
            return Stack(
              children: [
                const Positioned.fill(
                  child: LiquidMotionBackground(),
                ),
                ?child,
              ],
            );
          },
          home: !_hasCheckedLock
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _isLocked
                  ? PinScreen(
                      mode: PinScreenMode.unlock,
                      onPinVerifiedOrCreated: (_) => _onUnlocked(),
                    )
                  : const MainNavigationShell(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // ViewModels
  late final DashboardViewModel _dashboardViewModel;
  late final TransactionViewModel _transactionViewModel;
  late final AnalyticsViewModel _analyticsViewModel;
  late final SettingsViewModel _settingsViewModel;

  @override
  void initState() {
    super.initState();
    _dashboardViewModel = DashboardViewModel()..init();
    _transactionViewModel = TransactionViewModel()..init();
    _analyticsViewModel = AnalyticsViewModel()..init();
    _settingsViewModel = SettingsViewModel()..init();
  }

  void _refreshAll() {
    _dashboardViewModel.loadData();
    _transactionViewModel.loadTransactions();
    _analyticsViewModel.loadData();
    _settingsViewModel.init();
  }

  Future<void> _openAddTransaction({TransactionType type = TransactionType.expense}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionView(initialType: type),
      ),
    );
    if (result == true) {
      _refreshAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardView(
        viewModel: _dashboardViewModel,
        onAddExpense: () => _openAddTransaction(type: TransactionType.expense),
        onAddIncome: () => _openAddTransaction(type: TransactionType.income),
        onAddTransfer: () => _openAddTransaction(type: TransactionType.transfer),
        onViewAllTransactions: () => setState(() => _currentIndex = 1),
        onTransactionTap: (tx) async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditTransactionView(transactionToEdit: tx),
            ),
          );
          if (res == true) {
            _refreshAll();
          }
        },
      ),
      TransactionListView(
        viewModel: _transactionViewModel,
        onTransactionChanged: _refreshAll,
      ),
      AnalyticsView(
        viewModel: _analyticsViewModel,
      ),
      SettingsView(
        viewModel: _settingsViewModel,
        onDataResetOrRestored: _refreshAll,
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CurvedGlassNavBar(
                isDark: isDark,
                currentIndex: _currentIndex,
                onTap: (idx) {
                  setState(() => _currentIndex = idx);
                  if (idx == 0) _dashboardViewModel.loadData();
                  if (idx == 1) _transactionViewModel.loadTransactions();
                  if (idx == 2) _analyticsViewModel.loadData();
                  if (idx == 3) _settingsViewModel.init();
                },
                onAddTap: () => _openAddTransaction(type: TransactionType.expense),
              ),
            ),
          ),
    );
  }
}
