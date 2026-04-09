class GoalItem {
  const GoalItem({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.remainingAmount,
    required this.progress,
    required this.completionPercent,
    required this.status,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double remainingAmount;
  final double progress;
  final double completionPercent;
  final String status;

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    return GoalItem(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: _toDouble(json['targetAmount']),
      currentAmount: _toDouble(json['currentAmount']),
      remainingAmount: _toDouble(json['remainingAmount']),
      progress: _toDouble(json['progress']),
      completionPercent: _toDouble(json['completionPercent']),
      status: json['status'] as String,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
