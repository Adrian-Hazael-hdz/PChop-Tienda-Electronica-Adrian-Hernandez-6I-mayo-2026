import 'package:flutter/foundation.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepository();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Suma total calculada a partir de los subtotales
  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Cargar el carrito del usuario
  Future<void> fetchCart(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getCart(uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo cargar tu carrito de compras.';
      notifyListeners();
    }
  }

  // Agregar un producto al carrito (usa snapshots inmutables)
  Future<void> addItem(String uid, ProductModel product, int quantity) async {
    try {
      final item = CartItemModel(
        itemId: '',
        prodId: product.prodId,
        nombreSnapshot: product.nombre,
        precioSnapshot: product.precio,
        imagenUrlSnapshot: product.imagenUrl,
        cantidad: quantity,
        fechaAgregado: DateTime.now(),
      );
      await _repository.addToCart(uid, item);
      await fetchCart(uid);
    } catch (e) {
      debugPrint('Error en CartProvider.addItem: $e');
    }
  }

  // Modificar cantidad de un artículo
  Future<void> updateQuantity(String uid, String prodId, int newQuantity) async {
    if (newQuantity < 1) return;
    try {
      await _repository.updateQuantity(uid, prodId, newQuantity);
      await fetchCart(uid);
    } catch (e) {
      debugPrint('Error en CartProvider.updateQuantity: $e');
    }
  }

  // Eliminar un artículo del carrito
  Future<void> removeItem(String uid, String prodId) async {
    try {
      await _repository.removeFromCart(uid, prodId);
      await fetchCart(uid);
    } catch (e) {
      debugPrint('Error en CartProvider.removeItem: $e');
    }
  }

  // Limpiar el estado y Firestore
  Future<void> clear(String uid) async {
    try {
      await _repository.clearCart(uid);
      _items.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error en CartProvider.clear: $e');
    }
  }
}
