class CategoryModel {
  final String catId;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final int orden;

  CategoryModel({
    required this.catId,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.orden,
  });

  // Convertir de Map (Firestore) a Modelo
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      catId: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      orden: map['orden'] ?? 0,
    );
  }

  // Convertir de Modelo a Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'orden': orden,
    };
  }
}
