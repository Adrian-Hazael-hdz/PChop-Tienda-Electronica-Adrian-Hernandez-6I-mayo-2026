import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../app/routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<CartProvider>().fetchCart(user.uid);
        });
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
      ),
      body: cartProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : cartProvider.items.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    // Lista de artículos
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                        itemCount: cartProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.items[index];
                          return Card(
                            margin: const EdgeInsets.only(
                                bottom: AppConstants.kSpaceMD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kBorderRadiusCard),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            color: AppColors.surface,
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppConstants.kSpaceSM),
                              child: Row(
                                children: [
                                  // Miniatura de Imagen
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.kBorderRadiusThumbnail),
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      color: AppColors.divider,
                                      child: Image.network(
                                        item.imagenUrlSnapshot,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: AppColors.primaryDark);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.kSpaceMD),

                                  // Datos del producto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nombreSnapshot,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${item.precioSnapshot.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Controles de cantidad
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: AppColors.primaryDark),
                                        onPressed: item.cantidad > 1
                                            ? () {
                                                if (user != null) {
                                                  cartProvider.updateQuantity(
                                                      user.uid,
                                                      item.prodId,
                                                      item.cantidad - 1);
                                                }
                                              }
                                            : null,
                                      ),
                                      Text(
                                        '${item.cantidad}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: AppColors.primaryDark),
                                        onPressed: () {
                                          if (user != null) {
                                            cartProvider.updateQuantity(
                                                user.uid,
                                                item.prodId,
                                                item.cantidad + 1);
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  // Botón eliminar
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      if (user != null) {
                                        cartProvider.removeItem(
                                            user.uid, item.prodId);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Resumen y checkout
                    Container(
                      padding: const EdgeInsets.all(AppConstants.kSpaceLG),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(AppConstants.kBorderRadiusModal),
                          topRight:
                              Radius.circular(AppConstants.kBorderRadiusModal),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total estimado:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '\$${cartProvider.total.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: AppColors.primaryDark,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, Routes.checkout);
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Proceder al pago'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: AppColors.disabled,
            ),
            const SizedBox(height: AppConstants.kSpaceLG),
            Text(
              'Tu carrito está vacío',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: AppConstants.kSpaceSM),
            Text(
              'Explora nuestro catálogo y añade artículos a tu carrito.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.kSpaceXL),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.home);
              },
              child: const Text('Ir al Catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
