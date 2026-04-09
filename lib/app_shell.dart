import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/admin/screens/admin_users_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/family/screens/family_screen.dart';
import 'features/goals/screens/goals_screen.dart';
import 'features/transactions/screens/transactions_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Deseja sair para acessar com outra conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    await ref.read(authStateProvider.notifier).logout();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Sessão encerrada com sucesso')),
      );

    if (!mounted) {
      return;
    }

    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.valueOrNull;
    final isAdmin = currentUser?.isAdmin ?? false;

    final screens = <Widget>[
      const DashboardScreen(),
      const TransactionsScreen(),
      const GoalsScreen(),
      const FamilyScreen(),
      if (isAdmin) const AdminUsersScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        label: 'Transações',
      ),
      const NavigationDestination(
        icon: Icon(Icons.flag_outlined),
        label: 'Metas',
      ),
      const NavigationDestination(
        icon: Icon(Icons.family_restroom_outlined),
        label: 'Família',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          label: 'Admin',
        ),
    ];

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinMind AI+'),
        actions: [
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: destinations,
      ),
    );
  }
}
