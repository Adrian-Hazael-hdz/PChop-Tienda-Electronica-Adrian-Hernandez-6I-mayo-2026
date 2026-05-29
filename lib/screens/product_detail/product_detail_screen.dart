import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _LoginPromptDialog extends StatelessWidget {
  const _LoginPromptDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Autenticación Requerida'),
      content: const Text('Debes iniciar sesión para realizar esta acción.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final prodId = args['id'] as String;
      _loadProduct(prodId);
      _initialized = true;
    }
  }

  Future<void> _loadProduct(String prodId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      // Buscar en los productos cargados
      final cachedProduct = productProvider.products.firstWhere(
        (p) => p.prodId == prodId,
        orElse: () => productProvider.featuredProducts
            .firstWhere((p) => p.prodId == prodId),
      );
      setState(() {
        _product = cachedProduct;
        _isLoading = false;
      });
    } catch (e) {
      // Si no está en caché, cargarlo directamente de Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('productos')
            .doc(prodId)
            .get();
        if (doc.exists) {
          setState(() {
            _product = ProductModel.fromMap(doc.data()!, doc.id);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'El producto no existe.';
            _isLoading = false;
          });
        }
      } catch (err) {
        setState(() {
          _errorMessage = 'Error al cargar los detalles del producto.';
          _isLoading = false;
        });
      }
    }
  }

  void _showAddReviewDialog() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => const _LoginPromptDialog(),
      );
      return;
    }

    final commentController = TextEditingController();
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Escribir Reseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calificación:'),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        icon: Icon(
                          starVal <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.warning,
                          size: 32,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            selectedRating = starVal;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: AppConstants.kSpaceMD),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Comparte tu opinión sobre el producto...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;

                    Navigator.pop(context); // cerrar diálogo

                    // Capturar referencias antes del gap async
                    final productProvider = context.read<ProductProvider>();
                    final messenger = ScaffoldMessenger.of(context);

                    // Obtener el nombre del usuario de Firestore
                    String nombre = 'Usuario';
                    try {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(user.uid)
                          .get();
                      nombre = userDoc.data()?['nombre'] ??
                          user.email?.split('@')[0] ??
                          'Usuario';
                    } catch (e) {
                      debugPrint('Error obteniendo nombre: $e');
                    }

                    final success = await productProvider.addReview(
                      prodId: _product!.prodId,
                      clienteUid: user.uid,
                      clienteNombre: nombre,
                      calificacion: selectedRating,
                      comentario: commentController.text,
                    );

                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Reseña agregada con éxito.'
                              : 'Error al guardar la reseña.'),
                          backgroundColor:
                              success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    if (_isLoading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: Center(child: Text(_errorMessage ?? 'Producto no encontrado.')),
      );
    }

    final product = _product!;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen grande
            Container(
              height: 300,
              width: double.infinity,
              color: AppColors.divider,
              child: Image.network(
                product.imagenUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(Icons.image_not_supported, size: 64));
                },
              ),
            ),

            // Información general
            Padding(
              padding: const EdgeInsets.all(AppConstants.kSpaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.nombre,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Text(
                        '\$${product.precio.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                              AppConstants.kBorderRadiusBadge),
                        ),
                        child: Text(
                          product.categoriaNombre,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.kSpaceMD),
                      Icon(
                        product.stock > 0
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.stock > 0
                            ? 'En stock (${product.stock} u.)'
                            : 'Sin stock',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  product.stock > 0 ? Colors.green : Colors.red,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: AppConstants.kSpaceXL),

                  // Descripción
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  Text(
                    product.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Divider(height: AppConstants.kSpaceXL),

                  // Sección de Reseñas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Opiniones de clientes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: _showAddReviewDialog,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Escribir reseña'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),

                  // Stream de reseñas en tiempo real
                  StreamBuilder<List<ReviewModel>>(
                    stream: productProvider.getReviewsStream(product.prodId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Text('Error al cargar opiniones.');
                      }

                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppConstants.kSpaceMD),
                          child: Text(
                            'Aún no hay reseñas sobre este producto. ¡Sé el primero en calificarlo!',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.only(
                                bottom: AppConstants.kSpaceSM),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kBorderRadiusThumbnail),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppConstants.kSpaceMD),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.clienteNombreSnapshot,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: List.generate(5, (starIdx) {
                                          return Icon(
                                            starIdx < review.calificacion
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: AppColors.warning,
                                            size: 16,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppConstants.kSpaceXS),
                                  Text(
                                    review.comentario,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.kSpaceMD),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kBorderRadiusButton),
                    ),
                  ),
                  child: const Text('Volver'),
                ),
              ),
              const SizedBox(width: AppConstants.kSpaceMD),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: product.stock == 0
                      ? null
                      : () async {
                          final authProvider = context.read<AuthProvider>();
                          final user = authProvider.currentUser;
                          if (user == null) {
                            showDialog(
                              context: context,
                              builder: (context) => const _LoginPromptDialog(),
                            );
                            return;
                          }
                          final cartProvider = context.read<CartProvider>();
                          final messenger = ScaffoldMessenger.of(context);
                          await cartProvider.addItem(user.uid, product, 1);
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('¡Producto añadido al carrito!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: product.stock == 0
                        ? AppColors.disabled
                        : AppColors.primary,
                  ),
                  child: const Text('Añadir al carrito'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
