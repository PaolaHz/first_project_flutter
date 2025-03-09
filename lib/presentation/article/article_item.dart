// Dentro de home_page.dart, antes de la clase _HomePageState
import 'package:flutter/material.dart';
import 'package:parcial_moviles_1/data/datasources/local_storage.dart';

class ArticleItem extends StatelessWidget {
  final dynamic article;
  
  const ArticleItem(this.article, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? 'Sin título',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Agrega más campos según tu estructura de datos
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // Lógica para agregar a favoritos
                    LocalStorage.insertFavorite(article['id']);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}