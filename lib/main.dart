import 'package:flutter/material.dart';
import 'package:parcial_moviles_1/presentation/splash/splash.dart';

void main() {
  runApp(const ArticulosApp());
}

class ArticulosApp extends StatelessWidget {
  const ArticulosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck())
    ;
  }
}

