import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../shared/widgets/chart_widget.dart';
import '../../../shared/widgets/financial_card.dart';
import '../models/dashboard_data.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final dashboardData = dashboard.valueOrNull;
    final isRefreshing = dashboard.isLoading && dashboardData != null;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(dashboardProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Visão Financeira',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          if (dashboardData == null)
            dashboard.when(
              loading: () => Skeletonizer(
                enabled: true,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    SizedBox(
                      width: 170,
                      child: FinancialCard(
                        title: 'Saldo',
                        amount: 0,
                        icon: Icons.wallet,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: FinancialCard(
                        title: 'Entradas',
                        amount: 0,
                        icon: Icons.arrow_downward,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: FinancialCard(
                        title: 'Saídas',
                        amount: 0,
                        icon: Icons.arrow_upward,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: FinancialCard(
                        title: 'Reservado',
                        amount: 0,
                        icon: Icons.savings,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Falha ao carregar dashboard: $error'),
                ),
              ),
              data: (data) =>
                  _buildDashboardContent(context, data, isRefreshing: false),
            )
          else
            Stack(
              children: [
                AnimatedOpacity(
                  opacity: isRefreshing ? 0.72 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: _buildDashboardContent(
                    context,
                    dashboardData,
                    isRefreshing: isRefreshing,
                  ),
                ),
                if (isRefreshing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: const LinearProgressIndicator(minHeight: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardData data, {
    required bool isRefreshing,
  }) {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: FinancialCard(
                title: 'Saldo total',
                amount: data.balance,
                icon: Icons.account_balance_wallet,
                color: const Color(0xFF005F73),
              ),
            ),
            SizedBox(
              width: 170,
              child: FinancialCard(
                title: 'Entradas',
                amount: data.incomes,
                icon: Icons.trending_up,
                color: const Color(0xFF0A9396),
              ),
            ),
            SizedBox(
              width: 170,
              child: FinancialCard(
                title: 'Saídas',
                amount: data.expenses,
                icon: Icons.trending_down,
                color: const Color(0xFFAE2012),
              ),
            ),
            SizedBox(
              width: 170,
              child: FinancialCard(
                title: 'Reservado em metas',
                amount: data.reservedInGoals,
                icon: Icons.savings_outlined,
                color: const Color(0xFFCA6702),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score financeiro',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.score} pts',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo previsto (30d)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'R\$ ${data.futureBalance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gastos por categoria',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ChartWidget(byCategory: data.byCategory),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Conselheiro',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...data.advisorTips
                    .take(3)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $e'),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...data.insights
                    .take(3)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $e'),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alertas', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...data.alerts
                    .take(3)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $e'),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
