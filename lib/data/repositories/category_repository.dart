import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todas las categorías ordenadas por el campo 'orden'
  Future<List<CategoryModel>> getAll() async {
    try {
      final snapshot = await _db
          .collection('categorias')
          .orderBy('orden', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en CategoryRepository.getAll: $e');
      rethrow;
    }
  }
}
