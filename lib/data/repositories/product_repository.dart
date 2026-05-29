import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los productos activos
  Future<List<ProductModel>> getAll() async {
    try {
      final snapshot = await _db
          .collection('productos')
          .where('activo', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en ProductRepository.getAll: $e');
      rethrow;
    }
  }

  // Obtener producto por ID
  Future<ProductModel> getById(String prodId) async {
    try {
      final doc = await _db.collection('productos').doc(prodId).get();
      if (!doc.exists) {
        throw Exception('Producto no encontrado');
      }
      return ProductModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Error en ProductRepository.getById: $e');
      rethrow;
    }
  }

  // Obtener productos filtrados por categoría
  Future<List<ProductModel>> getByCategory(String categoryId) async {
    try {
      final snapshot = await _db
          .collection('productos')
          .where('activo', isEqualTo: true)
          .where('categoriaId', isEqualTo: categoryId)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en ProductRepository.getByCategory: $e');
      rethrow;
    }
  }

  // Obtener productos destacados (destacado == true)
  Future<List<ProductModel>> getFeatured() async {
    try {
      final snapshot = await _db
          .collection('productos')
          .where('activo', isEqualTo: true)
          .where('destacado', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en ProductRepository.getFeatured: $e');
      rethrow;
    }
  }

  // Obtener un Stream en tiempo real de las reseñas de un producto
  Stream<List<ReviewModel>> getReviewsStream(String prodId) {
    return _db
        .collection('productos')
        .doc(prodId)
        .collection('resenas')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Agregar una reseña a un producto
  Future<void> addReview(String prodId, ReviewModel review) async {
    try {
      await _db
          .collection('productos')
          .doc(prodId)
          .collection('resenas')
          .add(review.toMap());
    } catch (e) {
      debugPrint('Error en ProductRepository.addReview: $e');
      rethrow;
    }
  }
}
