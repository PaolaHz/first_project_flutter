class Articulo {
  final String nombre;
  final String vendedor;
  final String calificacion;
  final int imageId;
  bool esFavorito;

  Articulo({
    required this.nombre,
    required this.vendedor,
    required this.calificacion,
    required this.imageId,
    this.esFavorito = false,
  });
}