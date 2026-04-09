import 'package:financeiro/features/admin/controllers/admin_controller.dart';
import 'package:financeiro/features/admin/models/admin_user_item.dart';
import 'package:financeiro/features/admin/screens/admin_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

Widget _buildWithOverride(FutureOr<AdminUsersPage> Function() loader) {
  return ProviderScope(
    overrides: [adminUsersProvider.overrideWith((ref) async => await loader())],
    child: const MaterialApp(home: Scaffold(body: AdminUsersScreen())),
  );
}

void main() {
  testWidgets('shows loading state', (tester) async {
    final completer = Completer<AdminUsersPage>();

    await tester.pumpWidget(_buildWithOverride(() => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(
      const AdminUsersPage(
        items: [],
        total: 0,
        page: 1,
        pageSize: 10,
        totalPages: 1,
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('shows error state', (tester) async {
    await tester.pumpWidget(
      _buildWithOverride(() => throw Exception('Erro de teste')),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Falha ao carregar usuarios'), findsOneWidget);
  });

  testWidgets('shows empty state', (tester) async {
    await tester.pumpWidget(
      _buildWithOverride(
        () => Future.value(
          const AdminUsersPage(
            items: [],
            total: 0,
            page: 1,
            pageSize: 10,
            totalPages: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nenhum usuario encontrado para os filtros atuais'),
      findsOneWidget,
    );
  });

  testWidgets('shows users list data', (tester) async {
    final page = AdminUsersPage(
      items: [
        AdminUserItem(
          id: '1',
          name: 'Admin User',
          email: 'admin@finmind.ai',
          role: 'ADMIN',
          currency: 'BRL',
          createdAt: DateTime(2026, 4, 8),
        ),
      ],
      total: 1,
      page: 1,
      pageSize: 10,
      totalPages: 1,
    );

    await tester.pumpWidget(_buildWithOverride(() => Future.value(page)));
    await tester.pumpAndSettle();

    expect(find.text('Admin User'), findsOneWidget);
    expect(find.textContaining('admin@finmind.ai'), findsOneWidget);
  });
}
