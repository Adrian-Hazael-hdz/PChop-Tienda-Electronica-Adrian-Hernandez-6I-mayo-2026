import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Set document with try/catch
  Future<void> setDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).doc(docId).set(data);
    } catch (e) {
      debugPrint('Error en setDocument en $collectionPath/$docId: $e');
      rethrow;
    }
  }

  // Get document with try/catch
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String collectionPath, String docId) async {
    try {
      return await _db.collection(collectionPath).doc(docId).get();
    } catch (e) {
      debugPrint('Error en getDocument en $collectionPath/$docId: $e');
      rethrow;
    }
  }

  // Update document with try/catch
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      debugPrint('Error en updateDocument en $collectionPath/$docId: $e');
      rethrow;
    }
  }

  // Check if document exists
  Future<bool> documentExists(String collectionPath, String docId) async {
    try {
      final doc = await _db.collection(collectionPath).doc(docId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error en documentExists en $collectionPath/$docId: $e');
      return false;
    }
  }
}
