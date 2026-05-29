import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Campos de perfil de usuario
  String? _nombre;
  String _rol = 'usuario';
  DateTime? _fechaRegistro;

  AuthProvider() {
    // Escuchar los cambios de autenticación reactivamente
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        fetchProfile(user.uid);
      } else {
        _nombre = null;
        _rol = 'usuario';
        _fechaRegistro = null;
      }
      notifyListeners();
    });
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get nombre => _nombre;
  String get rol => _rol;
  DateTime? get fechaRegistro => _fechaRegistro;

  // Limpiar mensajes de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Correo exclusivo del administrador
  static const String _adminEmail = 'Admin123@gmail.com';

  // Cargar datos extendidos del perfil del usuario desde Firestore
  Future<void> fetchProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nombre = data['nombre'];
        // Si el correo es el del admin, forzar rol 'admin' siempre
        _rol = (_currentUser?.email?.toLowerCase() == _adminEmail.toLowerCase())
            ? 'admin'
            : (data['rol'] ?? 'usuario');
        _fechaRegistro = data['fechaRegistro'] != null
            ? (data['fechaRegistro'] as Timestamp).toDate()
            : null;
        notifyListeners();
      } else if (_currentUser?.email?.toLowerCase() == _adminEmail.toLowerCase()) {
        // El documento no existe pero es el admin → crear perfil y asignar rol
        _nombre = 'Administrador';
        _rol = 'admin';
        notifyListeners();
        // Crear documento del admin en Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'uid':           uid,
          'nombre':        'Administrador',
          'email':         _currentUser!.email,
          'rol':           'admin',
          'fechaRegistro': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error en AuthProvider.fetchProfile: $e');
    }
  }

  // Actualizar datos del perfil (nombre)
  Future<bool> updateProfile(String uid, String newNombre) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'nombre': newNombre.trim(),
      });
      _nombre = newNombre.trim();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo actualizar la información de perfil.';
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ocurrió un error inesperado al iniciar sesión.';
      notifyListeners();
      return false;
    }
  }

  // Registro de usuario
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        password: password,
        nombre: nombre,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ocurrió un error inesperado al registrar el usuario.';
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mapear códigos de error de Firebase Auth a español
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta de usuario ha sido desactivada.';
      case 'user-not-found':
        return 'No existe ningún usuario registrado con este correo.';
      case 'wrong-password':
        return 'La contraseña ingresada es incorrecta.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya se encuentra registrado.';
      case 'operation-not-allowed':
        return 'El inicio de sesión con correo y contraseña no está habilitado.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe contener un mínimo de 6 caracteres.';
      case 'invalid-credential':
        return 'Las credenciales no son válidas o han expirado.';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
