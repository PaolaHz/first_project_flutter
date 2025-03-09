// home_page.dart
import 'package:flutter/material.dart';
import 'package:parcial_moviles_1/data/datasources/api_service.dart';
import 'package:parcial_moviles_1/data/datasources/local_storage.dart';
import 'package:parcial_moviles_1/presentation/article/article_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _articles = [];
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final token = await LocalStorage.getToken();
    final articles = await ApiService().getArticles(token!);
    setState(() => _articles = articles);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await LocalStorage.clearDatabase();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isGridView 
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: _articles.length,
              itemBuilder: (context, index) => ArticleItem(_articles[index]),
            )
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) => ArticleItem(_articles[index]),
            ),
    );
  }
}