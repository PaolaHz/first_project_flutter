// auth_check.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:parcial_moviles_1/data/local_storage.dart';
import 'package:parcial_moviles_1/presentation/article/article_item.dart';
import 'package:parcial_moviles_1/presentation/login/login_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<String?> _getValidToken() async {
    final token = await MySharedPrefsHelper.getToken();
    if (token == null) return null;
    final isExpired = JwtDecoder.isExpired(token);
    return isExpired ? null : token;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getValidToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
             body: 
              Center(
                    child: Image.asset(
                      'assets/icons/logo.png',
                    ),
                  ),
          );
        }
        
        final token = snapshot.data;
        if (token != null) {
          return ArticulosScreen(jwtToken: token);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}