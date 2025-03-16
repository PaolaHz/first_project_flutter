import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:parcial_moviles_1/data/api_service.dart';
import 'package:parcial_moviles_1/data/local_storage.dart';
import 'package:parcial_moviles_1/presentation/article/article_item.dart';
import 'package:parcial_moviles_1/presentation/splash/splash.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  /// Método para manejar el login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String? token = await _apiService.validar(email, password);
    print("Login exitoso ----------------------!!!!!!!!!!!. Token: $token, userId: $token");

    if (token != null) {
      await MySharedPrefsHelper.saveToken(token); // Guardamos el JWT
      int userId = JwtDecoder.decode(token)['userId']; // Extraemos userId del token
      print("Login exitoso ----------------------!!!!!!!!!!!. Token: $token, userId: $userId");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArticulosScreen(jwtToken: token)),
      );
    } else {
      _showErrorDialog("Credenciales incorrectas. Inténtalo de nuevo.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Mostrar mensaje de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Iniciar Sesión",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text("Ingresar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
