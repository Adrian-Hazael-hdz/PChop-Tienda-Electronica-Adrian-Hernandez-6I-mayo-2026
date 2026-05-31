import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  // Variables for coupon system
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  double _discountPercentage = 0.0;
  bool _isApplyingCoupon = false;
  String? _couponMessage;

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isApplyingCoupon = true;
      _couponMessage = null;
    });

    try {
      final doc = await FirebaseFirestore.instance.collection('cupones').doc(code).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['activo'] == true) {
          setState(() {
            _appliedCoupon = code;
            _discountPercentage = (data['porcentaje'] as num?)?.toDouble() ?? 0.0;
            _couponMessage = 'Cupón aplicado con éxito (${_discountPercentage.toStringAsFixed(0)}%)';
          });
        } else {
          setState(() {
            _appliedCoupon = null;
            _discountPercentage = 0.0;
            _couponMessage = 'El cupón ya no es válido o está inactivo';
          });
        }
      } else {
        setState(() {
          _appliedCoupon = null;
          _discountPercentage = 0.0;
          _couponMessage = 'Cupón inválido o no existe';
        });
      }
    } catch (e) {
      setState(() {
        _appliedCoupon = null;
        _discountPercentage = 0.0;
        _couponMessage = 'Error al validar cupón';
      });
    } finally {
      setState(() {
        _isApplyingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discountPercentage = 0.0;
      _couponController.clear();
      _couponMessage = null;
    });
  }

  Future<void> _processCheckout(double finalTotal) async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    final success = await orderProvider.checkout(
      uid: user.uid,
      items: cartProvider.items,
      paymentMethod: _selectedPaymentMethod,
      total: finalTotal,
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

    final subtotal = cartProvider.total;
    final discountAmount = subtotal * (_discountPercentage / 100.0);
    final finalTotal = subtotal - discountAmount;

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
                  
                  // Sistema de Cupones
                  Text(
                    'Cupón de descuento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_appliedCoupon == null)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'Ingresa tu código',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.kSpaceSM),
                              ElevatedButton(
                                onPressed: _isApplyingCoupon ? null : _applyCoupon,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                child: _isApplyingCoupon
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text('Aplicar'),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_offer, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Text(
                                    _appliedCoupon!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(-${_discountPercentage.toStringAsFixed(0)}%)',
                                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: _removeCoupon,
                                tooltip: 'Quitar cupón',
                              ),
                            ],
                          ),
                        if (_couponMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _couponMessage!,
                            style: TextStyle(
                              color: _appliedCoupon != null ? AppColors.success : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
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
                      child: const Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('Efectivo contra entrega'),
                            value: 'efectivo',
                          ),
                          RadioListTile<String>(
                            title: Text('Tarjeta de Crédito / Débito (Simulado)'),
                            value: 'tarjeta',
                          ),
                          RadioListTile<String>(
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
                            Text('\$${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        if (_appliedCoupon != null) ...[
                          const SizedBox(height: AppConstants.kSpaceXS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Descuento (${_discountPercentage.toStringAsFixed(0)}%):'),
                              Text(
                                '-\$${discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.success),
                              ),
                            ],
                          ),
                        ],
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
                              '\$${finalTotal.toStringAsFixed(2)}',
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
                      onPressed: cartProvider.items.isEmpty ? null : () => _processCheckout(finalTotal),
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

