import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'models/transaction.dart';
import 'providers/finance_provider.dart';
import 'widgets/transaction_form.dart';
import 'widgets/financial_summary.dart';
import 'widgets/transaction_item.dart';

/// Entry point of the Dinerosync application.
///
/// Initializes Hive database, registers type adapters for data models,
/// and sets up the provider architecture before launching the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CategoryAdapter());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FinanceProvider()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the Dinerosync application.
///
/// Configures the Material Design theme, dark mode support,
/// and sets up the main navigation structure.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  /// Builds the application with theme configuration and routing.
  ///
  /// Sets up Material Design 3 theming with custom color schemes
  /// for both light and dark modes.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinerosync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Main screen of the application displaying financial data.
///
/// Shows transaction list, financial summary, and provides access
/// to transaction management features like adding, filtering, and viewing.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen widget.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State class for [HomeScreen].
///
/// Manages the UI state and user interactions for the main screen.
class _HomeScreenState extends State<HomeScreen> {
  /// Builds the home screen interface.
  ///
  /// Creates the app bar, transaction list, and floating action button
  /// with proper state management through [FinanceProvider].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinerosync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTransactionForm(context),
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          return Column(
            children: [
              _buildDateFilterChip(financeProvider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => financeProvider.init(),
                  child: _buildTransactionList(financeProvider),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the date filter chip widget.
  ///
  /// Shows the current date range filter if active, with an option
  /// to remove the filter. Returns empty widget if no filter is set.
  Widget _buildDateFilterChip(FinanceProvider provider) {
    final filter = provider.dateFilter;
    if (filter == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Chip(
        label: Text(
          '${DateFormat('dd MMM yyyy').format(filter.start)}'
          ' - ${DateFormat('dd MMM yyyy').format(filter.end)}',
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => provider.setDateFilter(null),
      ),
    );
  }

  /// Builds the main transaction list or empty state.
  ///
  /// Returns either a scrollable list with financial summary and
  /// transactions, or an empty state message when no data exists.
  Widget _buildTransactionList(FinanceProvider provider) {
    if (provider.transactions.isEmpty) {
      return Center(child: _buildEmptyState());
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: FinancialSummary()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final transaction = provider.transactions[index];
              return TransactionItem(transaction: transaction);
            }, childCount: provider.transactions.length),
          ),
        ),
      ],
    );
  }

  /// Builds the empty state widget when no transactions exist.
  ///
  /// Shows an icon, message, and instructions to encourage users
  /// to add their first transaction.
  Widget _buildEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 60),
        SizedBox(height: 16),
        Text('No hay transacciones registradas'),
        SizedBox(height: 8),
        Text('Presiona el botón + para agregar una'),
      ],
    );
  }

  /// Shows the date range picker dialog.
  ///
  /// Allows users to select a date range for filtering transactions.
  /// Updates the [FinanceProvider] with the selected range.
  Future<void> _selectDateRange(BuildContext context) async {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: financeProvider.dateFilter,
    );

    if (picked != null) {
      financeProvider.setDateFilter(picked);
    }
  }

  /// Shows the transaction form in a modal bottom sheet.
  ///
  /// Displays [TransactionForm] for creating new transactions or
  /// editing existing ones when [transaction] is provided.
  void _showTransactionForm(BuildContext context, {Transaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TransactionForm(transaction: transaction),
          ),
    );
  }
}
