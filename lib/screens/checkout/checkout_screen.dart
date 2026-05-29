import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../app/routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'efectivo'; // Default

  Future<void> _processCheckout() async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    final success = await orderProvider.checkout(
      uid: user.uid,
      items: cartProvider.items,
      paymentMethod: _selectedPaymentMethod,
      total: cartProvider.total,
    );

    if (mounted) {
      if (success) {
        // Limpiar el estado del carrito localmente también
        cartProvider.clear(user.uid);
        
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Compra realizada con éxito!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Volver a Home limpiando historial
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else {
        // Si falló por falta de stock o error de la transacción
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error al realizar compra'),
            content: Text(orderProvider.errorMessage ?? 'Ocurrió un error inesperado al procesar tu pedido.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
      ),
      body: orderProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: AppConstants.kSpaceMD),
                  Text('Procesando compra de forma segura...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.kSpaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de productos
                  Text(
                    'Resumen del pedido',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartProvider.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return ListTile(
                          title: Text(item.nombreSnapshot),
                          subtitle: Text('Cantidad: ${item.cantidad}'),
                          trailing: Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.kSpaceLG),

                  // Selector de método de pago
                  Text(
                    'Método de Pago',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: RadioGroup<String>(
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          const RadioListTile<String>(
                            title: Text('Efectivo contra entrega'),
                            value: 'efectivo',
                          ),
                          const RadioListTile<String>(
                            title: Text('Tarjeta de Crédito / Débito (Simulado)'),
                            value: 'tarjeta',
                          ),
                          const RadioListTile<String>(
                            title: Text('PayPal (Simulado)'),
                            value: 'paypal',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.kSpaceXL),

                  // Detalle de costos
                  Container(
                    padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('\$${cartProvider.total.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: AppConstants.kSpaceXS),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Costo de envío:'),
                            Text('Gratis', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: AppConstants.kSpaceLG),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total final:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '\$${cartProvider.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.kSpaceXL),

                  // Botón confirmar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cartProvider.items.isEmpty ? null : _processCheckout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirmar Compra'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
