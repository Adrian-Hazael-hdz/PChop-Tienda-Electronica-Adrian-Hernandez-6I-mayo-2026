import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Inicio de sesión
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('Error en login: $e');
      rethrow;
    }
  }

  // Registro y creación de documento del usuario en Firestore
  Future<UserCredential> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // Guardar información del usuario en usuarios/{uid}
        await _firestoreService.setDocument('usuarios', user.uid, {
          'uid': user.uid,
          'nombre': nombre.trim(),
          'email': user.email ?? email.trim(),
          'rol': 'usuario',
          'fechaRegistro': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } catch (e) {
      debugPrint('Error en register: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error en signOut: $e');
      rethrow;
    }
  }
}
