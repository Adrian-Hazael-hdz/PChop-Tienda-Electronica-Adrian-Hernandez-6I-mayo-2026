import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String itemId;
  final String prodId;
  final String nombreSnapshot;
  final double precioSnapshot;
  final String imagenUrlSnapshot;
  final int cantidad;
  final DateTime fechaAgregado;

  CartItemModel({
    required this.itemId,
    required this.prodId,
    required this.nombreSnapshot,
    required this.precioSnapshot,
    required this.imagenUrlSnapshot,
    required this.cantidad,
    required this.fechaAgregado,
  });

  // Calcular subtotal de este elemento del carrito
  double get subtotal => precioSnapshot * cantidad;

  // Convertir de Map (Firestore) a Modelo
  factory CartItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CartItemModel(
      itemId: id,
      prodId: map['prodId'] ?? '',
      nombreSnapshot: map['nombreSnapshot'] ?? '',
      precioSnapshot: (map['precioSnapshot'] ?? 0.0).toDouble(),
      imagenUrlSnapshot: map['imagenUrlSnapshot'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      fechaAgregado: map['fechaAgregado'] != null
          ? (map['fechaAgregado'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir de Modelo a Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'prodId': prodId,
      'nombreSnapshot': nombreSnapshot,
      'precioSnapshot': precioSnapshot,
      'imagenUrlSnapshot': imagenUrlSnapshot,
      'cantidad': cantidad,
      'fechaAgregado': Timestamp.fromDate(fechaAgregado),
    };
  }

  // Convertir a Map para incrustar en un documento de pedido (Order)
  Map<String, dynamic> toOrderMap() {
    return {
      'prodId': prodId,
      'nombreSnapshot': nombreSnapshot,
      'precioSnapshot': precioSnapshot,
      'imagenUrlSnapshot': imagenUrlSnapshot,
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }
}
