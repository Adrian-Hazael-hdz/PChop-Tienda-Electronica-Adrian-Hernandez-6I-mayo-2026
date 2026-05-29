import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los elementos del carrito de un usuario
  Future<List<CartItemModel>> getCart(String uid) async {
    try {
      final snapshot = await _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .orderBy('fechaAgregado', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en CartRepository.getCart: $e');
      rethrow;
    }
  }

  // Agregar artículo al carrito (si ya existe, suma la cantidad)
  Future<void> addToCart(String uid, CartItemModel item) async {
    try {
      final docRef = _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .doc(item.prodId);

      final doc = await docRef.get();
      if (doc.exists) {
        final currentQty = doc.data()?['cantidad'] ?? 0;
        await docRef.update({'cantidad': currentQty + item.cantidad});
      } else {
        await docRef.set(item.toMap());
      }
    } catch (e) {
      debugPrint('Error en CartRepository.addToCart: $e');
      rethrow;
    }
  }

  // Actualizar cantidad de un artículo en el carrito
  Future<void> updateQuantity(String uid, String prodId, int newQuantity) async {
    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .doc(prodId)
          .update({'cantidad': newQuantity});
    } catch (e) {
      debugPrint('Error en CartRepository.updateQuantity: $e');
      rethrow;
    }
  }

  // Eliminar un artículo del carrito
  Future<void> removeFromCart(String uid, String prodId) async {
    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .doc(prodId)
          .delete();
    } catch (e) {
      debugPrint('Error en CartRepository.removeFromCart: $e');
      rethrow;
    }
  }

  // Vaciar el carrito (utilizando WriteBatch para mayor eficiencia)
  Future<void> clearCart(String uid) async {
    try {
      final batch = _db.batch();
      final snapshot = await _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error en CartRepository.clearCart: $e');
      rethrow;
    }
  }
}
