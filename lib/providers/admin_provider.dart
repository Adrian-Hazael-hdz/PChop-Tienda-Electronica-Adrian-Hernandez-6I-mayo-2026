import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/models/order_model.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<OrderModel> _orders = [];
  List<Map<String, dynamic>> _users = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<OrderModel> get orders => _orders;
  List<Map<String, dynamic>> get users => _users;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cargar todos los productos (incluyendo inactivos)
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('productos')
          .orderBy('fechaCreacion', descending: true)
          .get();
      _products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los productos del panel.';
      notifyListeners();
    }
  }

  // Guardar o actualizar un producto
  Future<bool> saveProduct(ProductModel prod) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (prod.prodId.isEmpty) {
        // Crear
        final docRef = _db.collection('productos').doc();
        await docRef.set({
          ...prod.toMap(),
          'fechaCreacion': FieldValue.serverTimestamp(),
        });
      } else {
        // Editar
        await _db.collection('productos').doc(prod.prodId).update(prod.toMap());
      }
      await fetchProducts();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo guardar el producto.';
      notifyListeners();
      return false;
    }
  }

  // Alternar estado activo del producto (Soft delete)
  Future<bool> toggleProductActive(String prodId, bool currentStatus) async {
    try {
      await _db.collection('productos').doc(prodId).update({'activo': !currentStatus});
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint('Error en toggleProductActive: $e');
      return false;
    }
  }

  // Cargar todas las categorías
  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('categorias')
          .orderBy('orden', descending: false)
          .get();
      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron obtener las categorías.';
      notifyListeners();
    }
  }

  // Guardar o actualizar una categoría
  Future<bool> saveCategory(CategoryModel cat) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (cat.catId.isEmpty) {
        // Crear
        final docRef = _db.collection('categorias').doc();
        await docRef.set(cat.toMap());
      } else {
        // Editar
        await _db.collection('categorias').doc(cat.catId).update(cat.toMap());
      }
      await fetchCategories();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo guardar la categoría.';
      notifyListeners();
      return false;
    }
  }

  // Cargar todos los usuarios registrados
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('usuarios')
          .orderBy('fechaRegistro', descending: true)
          .get();
      _users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'nombre': data['nombre'] ?? '',
          'email': data['email'] ?? '',
          'rol': data['rol'] ?? 'usuario',
          'fechaRegistro': data['fechaRegistro'] != null
              ? (data['fechaRegistro'] as Timestamp).toDate()
              : null,
        };
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron obtener los usuarios.';
      notifyListeners();
    }
  }

  // Cargar todos los pedidos realizados
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('pedidos')
          .orderBy('fecha', descending: true)
          .get();
      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron obtener los pedidos.';
      notifyListeners();
    }
  }

  // Actualizar estado de un pedido
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('pedidos').doc(orderId).update({'estado': newStatus});
      await fetchOrders();
      return true;
    } catch (e) {
      debugPrint('Error en updateOrderStatus: $e');
      return false;
    }
  }
}
