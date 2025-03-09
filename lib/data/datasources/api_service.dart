import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configura la URL base de tu backend
  static const String _baseUrl = 'http://:3000/api'; // Para Android emulator

  // Método para login
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token']; // Extrae el JWT del response
    } else {
      throw Exception('Error en login: ${response.statusCode}');
    }
  }

  // Método para obtener artículos
  Future<List<dynamic>> getArticles(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/articles'),
      headers: {
        'Authorization': 'Bearer $token', // Envía el JWT en el header
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retorna la lista de artículos
    } else {
      throw Exception('Error cargando artículos: ${response.statusCode}');
    }
  }
}