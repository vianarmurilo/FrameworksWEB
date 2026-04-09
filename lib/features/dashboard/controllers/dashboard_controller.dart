import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';
import '../../transactions/controllers/transactions_controller.dart';
import '../../goals/controllers/goals_controller.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(dioProvider));
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  ref.watch(transactionsMutationProvider);
  ref.watch(goalsMutationProvider);
  final payload = await ref.watch(dashboardServiceProvider).fetchOverview();
  return DashboardData.fromPayload(
    analytics: payload['analytics'] as Map<String, dynamic>,
    alerts: payload['alerts'] as Map<String, dynamic>,
    prediction: payload['prediction'] as Map<String, dynamic>,
    gamification: payload['gamification'] as Map<String, dynamic>,
    advisor: payload['advisor'] as Map<String, dynamic>,
  );
});
