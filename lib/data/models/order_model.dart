import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String pedidoId;
  final String clienteUid;
  final DateTime fecha;
  final String estado; // 'pendiente' | 'procesando' | 'enviado' | 'entregado' | 'cancelado'
  final double total;
  final List<CartItemModel> items; // Mapeados desde la estructura interna
  final OrderPayment payment;

  OrderModel({
    required this.pedidoId,
    required this.clienteUid,
    required this.fecha,
    required this.estado,
    required this.total,
    required this.items,
    required this.payment,
  });

  // Convertir de Map (Firestore) a Modelo
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final List<dynamic> itemsList = map['items'] ?? [];
    
    return OrderModel(
      pedidoId: id,
      clienteUid: map['clienteUid'] ?? '',
      fecha: map['fecha'] != null
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      estado: map['estado'] ?? 'pendiente',
      total: (map['total'] ?? 0.0).toDouble(),
      items: itemsList.map((itemMap) {
        return CartItemModel(
          itemId: '', // No tiene ID individual en la lista incrustada
          prodId: itemMap['prodId'] ?? '',
          nombreSnapshot: itemMap['nombreSnapshot'] ?? '',
          precioSnapshot: (itemMap['precioSnapshot'] ?? 0.0).toDouble(),
          imagenUrlSnapshot: itemMap['imagenUrlSnapshot'] ?? '',
          cantidad: itemMap['cantidad'] ?? 1,
          fechaAgregado: DateTime.now(),
        );
      }).toList(),
      payment: OrderPayment.fromMap(map['pago'] ?? {}),
    );
  }

  // Convertir de Modelo a Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'clienteUid': clienteUid,
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
      'total': total,
      'items': items.map((item) => item.toOrderMap()).toList(),
      'pago': payment.toMap(),
    };
  }
}

class OrderPayment {
  final String metodo; // 'efectivo' | 'tarjeta' | 'paypal'
  final String estado; // 'simulado'
  final DateTime fechaPago;

  OrderPayment({
    required this.metodo,
    required this.estado,
    required this.fechaPago,
  });

  factory OrderPayment.fromMap(Map<String, dynamic> map) {
    return OrderPayment(
      metodo: map['metodo'] ?? 'efectivo',
      estado: map['estado'] ?? 'simulado',
      fechaPago: map['fechaPago'] != null
          ? (map['fechaPago'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metodo': metodo,
      'estado': estado,
      'fechaPago': Timestamp.fromDate(fechaPago),
    };
  }
}
