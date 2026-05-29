import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cargar todos los productos activos
  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los productos.';
      notifyListeners();
    }
  }

  // Cargar productos destacados
  Future<void> fetchFeatured() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _featuredProducts = await _repository.getFeatured();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los productos destacados.';
      notifyListeners();
    }
  }

  // Cargar productos por categoría
  Future<void> fetchByCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los productos de la categoría.';
      notifyListeners();
    }
  }

  // Obtener Stream de reseñas de un producto
  Stream<List<ReviewModel>> getReviewsStream(String prodId) {
    return _repository.getReviewsStream(prodId);
  }

  // Agregar una reseña
  Future<bool> addReview({
    required String prodId,
    required String clienteUid,
    required String clienteNombre,
    required int calificacion,
    required String comentario,
  }) async {
    try {
      final review = ReviewModel(
        resenaId: '',
        clienteUid: clienteUid,
        clienteNombreSnapshot: clienteNombre,
        calificacion: calificacion,
        comentario: comentario,
        fecha: DateTime.now(),
      );
      await _repository.addReview(prodId, review);
      return true;
    } catch (e) {
      debugPrint('Error en ProductProvider.addReview: $e');
      return false;
    }
  }
}
