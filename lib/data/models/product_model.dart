import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String prodId;
  final String categoriaId;
  final String categoriaNombre;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String imagenUrl;
  final bool activo;
  final bool destacado;
  final DateTime fechaCreacion;

  ProductModel({
    required this.prodId,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imagenUrl,
    required this.activo,
    required this.destacado,
    required this.fechaCreacion,
  });

  // Convertir de Map (Firestore) a Modelo
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      prodId: id,
      categoriaId: map['categoriaId'] ?? '',
      categoriaNombre: map['categoriaNombre'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      imagenUrl: map['imagenUrl'] ?? '',
      activo: map['activo'] ?? true,
      destacado: map['destacado'] ?? false,
      fechaCreacion: map['fechaCreacion'] != null 
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir de Modelo a Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'categoriaId': categoriaId,
      'categoriaNombre': categoriaNombre,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagenUrl': imagenUrl,
      'activo': activo,
      'destacado': destacado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}
