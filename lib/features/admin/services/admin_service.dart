import 'package:dio/dio.dart';
import '../models/admin_user_item.dart';

class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AdminService {
  const AdminService(this._dio);

  final Dio _dio;

  Future<AdminUsersPage> listUsers({
    required int page,
    required int pageSize,
    String? search,
    required String sortOrder,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'sortOrder': sortOrder,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      return AdminUsersPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401) {
        throw const AdminException('Sessão expirada. Faça login novamente.');
      }
      if (status == 403) {
        throw const AdminException('Acesso negado. Você não tem permissão de administrador.');
      }

      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message'] as String?)
          : null;

      throw AdminException(message ?? 'Falha ao carregar usuários cadastrados.');
    } catch (_) {
      throw const AdminException('Falha ao carregar usuários cadastrados.');
    }
  }
}
