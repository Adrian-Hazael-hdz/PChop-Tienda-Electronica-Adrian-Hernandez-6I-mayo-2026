import 'package:flutter/foundation.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cargar historial de pedidos
  Future<void> fetchOrders(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repository.getOrders(uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo obtener tu historial de pedidos.';
      notifyListeners();
    }
  }

  // Confirmar compra con transacción de stock
  Future<bool> checkout({
    required String uid,
    required List<CartItemModel> items,
    required String paymentMethod,
    required double total,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = OrderModel(
        pedidoId: '',
        clienteUid: uid,
        fecha: DateTime.now(),
        estado: 'pendiente',
        total: total,
        items: items,
        payment: OrderPayment(
          metodo: paymentMethod,
          estado: 'simulado',
          fechaPago: DateTime.now(),
        ),
      );

      await _repository.placeOrder(order);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      // Extraer un mensaje de error limpio sin la palabra "Exception: "
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
