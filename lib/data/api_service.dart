import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'database_helper.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.70:3000/api';

  /// Método para validar credenciales y obtener el token JWT
  Future<String?> validar(String email, String password) async {

    print("Validando credenciales... email:$email, password: $password");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
        print("Token JWT ------------------!._!_!_!_!_!_!_!_!_!: ${response.body}");

      if (response.statusCode == 200) {
        print("Autenticación exitosa. --------------- !!!_!_!_!_!"); 
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['token']; // Retorna el token si la autenticación es exitosa

      } else {
        print("Error de autenticación: ${response.body}");

        return null;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return null;
    }
  }

  /// Método para extraer el userId del token JWT
  int? extractUserId(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['userId']; // Ajusta esto según el campo de tu JWT
    } catch (e) {
      print("Error al decodificar el token: $e");
      return null;
    }
  }

  /// Método para obtener y guardar los artículos en SQLite
  Future<void> fetchAndSaveItems(jwtTokenReceived) async {

    await DatabaseHelper.instance.deleteAllItems(); // Elimina todos los ítems actuales
    print("Obteniendo y guardando ítems..., token: $jwtTokenReceived");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/articles'),
        headers: {'Authorization': 'Bearer $jwtTokenReceived'},
      );

      if (response.statusCode == 200) {
        
        List<dynamic> items = jsonDecode(response.body);

        for (var item in items) {
          // Verificación de que todos los campos estén presentes y sean válidos
          final itemToInsert = {
            'id': item['id'], 
            'user_id': item['usuario_id'] ?? '0', 
            'image_id': item['imagen_id'] ?? 1,
            'rating': item['rating'] ?? 0, 
            'itemName': item['nombre'] ?? '', 
            'vendedor': item['vendedor'] ?? '', 
            'calification': item['calificacion']?.toString() ?? '0', 
          };

          await DatabaseHelper.instance.insertItem(itemToInsert);
        }

        print("Ítems guardados en SQLite correctamente.");
      } else {
        print("Error al obtener ítems: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }
}