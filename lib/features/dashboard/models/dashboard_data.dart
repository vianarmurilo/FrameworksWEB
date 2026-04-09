class DashboardData {
  const DashboardData({
    required this.incomes,
    required this.expenses,
    required this.balance,
    required this.reservedInGoals,
    required this.dailyAverageExpense,
    required this.insights,
    required this.alerts,
    required this.byCategory,
    required this.futureBalance,
    required this.score,
    required this.advisorTips,
  });

  final double incomes;
  final double expenses;
  final double balance;
  final double reservedInGoals;
  final double dailyAverageExpense;
  final List<String> insights;
  final List<String> alerts;
  final List<CategoryExpense> byCategory;
  final double futureBalance;
  final int score;
  final List<String> advisorTips;

  factory DashboardData.fromPayload({
    required Map<String, dynamic> analytics,
    required Map<String, dynamic> alerts,
    required Map<String, dynamic> prediction,
    required Map<String, dynamic> gamification,
    required Map<String, dynamic> advisor,
  }) {
    final totals =
        analytics['totals'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final categoryItems = (analytics['byCategory'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final insights = (analytics['insights'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final alertItems = (alerts['alerts'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final advisorTips = (advisor['recommendations'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return DashboardData(
      incomes: (totals['incomes'] as num?)?.toDouble() ?? 0,
      expenses: (totals['expenses'] as num?)?.toDouble() ?? 0,
      balance: (totals['balance'] as num?)?.toDouble() ?? 0,
      reservedInGoals: (totals['reservedInGoals'] as num?)?.toDouble() ?? 0,
      dailyAverageExpense:
          (analytics['dailyAverageExpense'] as num?)?.toDouble() ?? 0,
      insights: insights,
      alerts: alertItems.map((item) => item['message'].toString()).toList(),
      byCategory: categoryItems
          .map(
            (item) => CategoryExpense(
              name: (item['category'] ?? 'Sem categoria').toString(),
              amount: _toDashboardDouble(item['amount']),
            ),
          )
          .toList(),
      futureBalance: (prediction['futureBalance'] as num?)?.toDouble() ?? 0,
      score: (gamification['points'] as num?)?.toInt() ?? 0,
      advisorTips: advisorTips,
    );
  }
}

class CategoryExpense {
  const CategoryExpense({required this.name, required this.amount});

  final String name;
  final double amount;
}

double _toDashboardDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
