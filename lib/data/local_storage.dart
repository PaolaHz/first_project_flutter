import 'package:shared_preferences/shared_preferences.dart';

class MySharedPrefsHelper {
  static const String _jwtKey = 'jwt_token';

  /// Guardar el JWT en SharedPreferences
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, token);
  }

  /// Obtener el JWT de SharedPreferences
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  /// Eliminar el JWT (para logout)
  static Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
  }
}
