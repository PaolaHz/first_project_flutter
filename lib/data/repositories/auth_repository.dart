// auth_repository.dart
import '../datasources/api_service.dart';
import '../datasources/local_storage.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<String> login(String email, String password) async {
    final token = await _apiService.login(email, password);
    await LocalStorage.saveToken(token);
    return token;
  }
}