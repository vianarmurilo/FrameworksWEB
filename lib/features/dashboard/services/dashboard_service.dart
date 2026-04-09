import 'package:dio/dio.dart';

class DashboardService {
  const DashboardService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchOverview() async {
    try {
      final results = await Future.wait([
        _dio.get('/analytics/overview'),
        _dio.get('/alerts'),
        _dio.get('/prediction?daysAhead=30'),
        _dio.get('/gamification'),
        _dio.get('/advisor?months=12'),
      ], eagerError: false);

      return {
        'analytics': _safeData(results[0]),
        'alerts': _safeData(results[1]),
        'prediction': _safeData(results[2]),
        'gamification': _safeData(results[3]),
        'advisor': _safeData(results[4]),
      };
    } catch (e) {
      // Fallback para dados vazios em caso de erro
      return {
        'analytics': {
          'totals': {},
          'byCategory': [],
          'insights': [],
          'dailyAverageExpense': 0,
        },
        'alerts': {'alerts': []},
        'prediction': {'futureBalance': 0},
        'gamification': {'points': 0},
        'advisor': {'recommendations': []},
      };
    }
  }

  Map<String, dynamic> _safeData(dynamic response) {
    try {
      if (response is DioException) {
        return <String, dynamic>{};
      }
      return (response?.data as Map<String, dynamic>?) ?? <String, dynamic>{};
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}
