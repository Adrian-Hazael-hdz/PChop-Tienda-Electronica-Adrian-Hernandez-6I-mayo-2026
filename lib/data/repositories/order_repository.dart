import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Procesar pedido de forma atómica
  Future<void> placeOrder(OrderModel order) async {
    try {
      await _db.runTransaction((transaction) async {
        final List<DocumentReference> prodRefs = [];
        final List<int> currentStocks = [];

        // 1. Validar disponibilidad de stock de todos los artículos
        for (var item in order.items) {
          final prodRef = _db.collection('productos').doc(item.prodId);
          final prodDoc = await transaction.get(prodRef);

          if (!prodDoc.exists) {
            throw Exception('El producto "${item.nombreSnapshot}" no existe en el catálogo.');
          }

          final int currentStock = prodDoc.data()?['stock'] ?? 0;
          if (currentStock < item.cantidad) {
            throw Exception('Stock insuficiente para "${item.nombreSnapshot}". Disponible: $currentStock unidades.');
          }

          prodRefs.add(prodRef);
          currentStocks.add(currentStock);
        }

        // 2. Decrementar el stock
        for (int i = 0; i < order.items.length; i++) {
          final item = order.items[i];
          final ref = prodRefs[i];
          final currentStock = currentStocks[i];
          transaction.update(ref, {'stock': currentStock - item.cantidad});
        }

        // 3. Registrar el documento de pedido en pedidos/
        final newOrderRef = _db.collection('pedidos').doc();
        transaction.set(newOrderRef, order.toMap());

        // 4. Limpiar los elementos del carrito del usuario en la base de datos
        final cartSnapshot = await _db
            .collection('usuarios')
            .doc(order.clienteUid)
            .collection('carrito')
            .get();

        for (var doc in cartSnapshot.docs) {
          transaction.delete(doc.reference);
        }
      });
    } catch (e) {
      debugPrint('Error en OrderRepository.placeOrder: $e');
      rethrow;
    }
  }

  // Obtener historial de pedidos de un cliente ordenados por fecha descendente
  Future<List<OrderModel>> getOrders(String uid) async {
    try {
      final snapshot = await _db
          .collection('pedidos')
          .where('clienteUid', isEqualTo: uid)
          .orderBy('fecha', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en OrderRepository.getOrders: $e');
      rethrow;
    }
  }
}
