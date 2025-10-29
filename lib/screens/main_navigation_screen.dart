import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../widgets/transaction_form.dart';
import 'transactions_screen.dart';
import 'summary_screen.dart';
// import 'profile_screen.dart';

// --- MODELO DE NAVEGACIÓN ---
// Define cada elemento de nuestra navegación de forma clara y explícita.
class _NavigationItem {
  final Widget screen;
  final IconData icon;
  final String label;
  final bool isAction; // Marca si es un botón de acción (como 'Añadir')

  const _NavigationItem({
    required this.screen,
    required this.icon,
    required this.label,
    this.isAction = false,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Nuestro índice ahora apunta a la lista de elementos de navegación REALES
  int _currentIndex = 0;

  // --- LISTA ÚNICA Y CENTRALIZADA ---
  // Esta es la única fuente de verdad para nuestra navegación.
  // El orden aquí es el que se mostrará.
  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      screen: DashboardScreen(),
      icon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavigationItem(
      screen: TransactionsScreen(),
      icon: Icons.receipt_long,
      label: 'Transacciones',
    ),
    _NavigationItem(
      screen: Container(),
      icon: Icons.add_circle,
      label: 'Añadir',
      isAction: true,
    ), // El widget es un placeholder
    _NavigationItem(
      screen: SummaryScreen(),
      icon: Icons.pie_chart,
      label: 'Resumen',
    ),
    // _NavigationItem(
    //   screen: ProfileScreen(),
    //   icon: Icons.person,
    //   label: 'Perfil',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        // El índice ahora corresponde directamente a nuestra lista de navegación
        index: _currentIndex,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          // El currentIndex sigue siendo el mismo, pero ahora su significado es claro
          currentIndex: _currentIndex,
          onTap: (index) => _onItemTapped(index),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Construimos los items del BottomNavigationBar a partir de nuestra lista
          items: _navigationItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // --- LÓGICA DE NAVEGACIÓN LIMPIA Y EXPLÍCITA ---
  void _onItemTapped(int index) {
    final selectedItem = _navigationItems[index];

    if (selectedItem.isAction) {
      // Si es un botón de acción, ejecutamos su lógica especial
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const TransactionForm(),
      );
      // No cambiamos el índice, por lo que la pantalla actual no se mueve
      return;
    }

    // Si no es una acción, simplemente navegamos a la pantalla correspondiente
    setState(() {
      _currentIndex = index;
    });
  }
}
