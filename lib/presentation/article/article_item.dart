import 'package:flutter/material.dart';
import 'package:parcial_moviles_1/data/api_service.dart';
import 'package:parcial_moviles_1/data/database_helper.dart';
import 'package:parcial_moviles_1/data/local_storage.dart';
import 'package:parcial_moviles_1/domain/articulo.dart';
import 'package:parcial_moviles_1/presentation/login/login_page.dart';

class ArticulosScreen extends StatefulWidget {
  final String jwtToken;
  const ArticulosScreen({Key? key, required this.jwtToken}) : super(key: key);

  @override
  _ArticulosScreenState createState() => _ArticulosScreenState();
}

class _ArticulosScreenState extends State<ArticulosScreen> {

  final ApiService _apiService = ApiService();
  List<Articulo> articulos = [];

  Future<void> _loadItems() async {
    await _apiService.fetchAndSaveItems(widget.jwtToken); 
    final List<Articulo> items = await DatabaseHelper.instance.getAllArticulos();
    setState(() {
      articulos = items;  
    });
  }


  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  bool vistaLista = true;
  bool mostrarFavoritos = false;

  void cambiarVista() {
    setState(() {
      vistaLista = !vistaLista;
    });
  }

  void toggleFavorito(int index) {
    setState(() {
      articulos[index].esFavorito = !articulos[index].esFavorito;
    });
  }

  void toggleMostrarFavoritos() {
    setState(() {
      mostrarFavoritos = !mostrarFavoritos;
    });
  }

   // Método para cerrar sesión
  void _logout() async {
    await DatabaseHelper.instance.deleteAllItems(); // Eliminar todos los artículos de sqlite
    await MySharedPrefsHelper.removeToken(); // Eliminar el token
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<Articulo> listaFiltrada = mostrarFavoritos
        ? articulos.where((articulo) => articulo.esFavorito).toList()
        : articulos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Artículos'),
        actions: [
          IconButton(
            icon: Icon(mostrarFavoritos ? Icons.star : Icons.star_border),
            onPressed: toggleMostrarFavoritos,
          ),
            IconButton( 
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: vistaLista ? _buildLista(listaFiltrada) : _buildCuadricula(listaFiltrada),
      floatingActionButton: FloatingActionButton(
        onPressed: cambiarVista,
        child: Icon(vistaLista ? Icons.grid_view : Icons.list),
      ),
    );
  }

  Widget _buildLista(List<Articulo> lista) {
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final articulo = lista[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/${articulo.imageId}.png'),
                  fit: BoxFit.cover,
                )
              ),
            ) 
          ),
          title: Text(articulo.nombre),
         
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(articulo.vendedor),
              Text('Calificación: ${articulo.calificacion}')
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              articulo.esFavorito ? Icons.star : Icons.star_border,
              color: articulo.esFavorito ? Colors.yellow : null,
            ),
            onPressed: () => toggleFavorito(articulos.indexOf(articulo)),
          ),
        );
      },
    );
  }

  Widget _buildCuadricula(List<Articulo> lista) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final articulo = lista[index];
        return Card(
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                color: Colors.blue,
                alignment: Alignment.center,
                child:  Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/${articulo.imageId}.png'),
                  fit: BoxFit.cover,
                )
              ),
            ) 
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(articulo.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(articulo.vendedor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calificación: ${articulo.calificacion}'),
                        IconButton(
                          icon: Icon(
                            articulo.esFavorito ? Icons.star : Icons.star_border,
                            color: articulo.esFavorito ? Colors.yellow : null,
                          ),
                          onPressed: () => toggleFavorito(articulos.indexOf(articulo)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
