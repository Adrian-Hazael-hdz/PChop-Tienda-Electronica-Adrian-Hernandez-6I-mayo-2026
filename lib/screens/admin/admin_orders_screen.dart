import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _statusFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchOrders();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    // Filtrar pedidos según el estado seleccionado
    final filteredOrders = _statusFilter == 'Todos'
        ? adminProvider.orders
        : adminProvider.orders.where((o) => o.estado == _statusFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Pedidos'),
      ),
      body: Column(
        children: [
          // Selector de filtro de estado horizontal
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: AppConstants.kSpaceSM),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.kSpaceMD),
              children: [
                'Todos',
                'pendiente',
                'procesando',
                'enviado',
                'entregado',
                'cancelado'
              ].map((status) {
                final isSelected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.kSpaceSM),
                  child: ChoiceChip(
                    label: Text(status.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _statusFilter = status;
                        });
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Lista de pedidos
          Expanded(
            child: adminProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : filteredOrders.isEmpty
                    ? const Center(
                        child: Text('No hay pedidos en este estado.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(
                                bottom: AppConstants.kSpaceMD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kBorderRadiusCard),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                'Pedido #${order.pedidoId.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Fecha: ${_formatDate(order.fecha)} | Total: \$${order.total.toStringAsFixed(2)}',
                              ),
                              childrenPadding:
                                  const EdgeInsets.all(AppConstants.kSpaceMD),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                const Divider(),
                                // Items del pedido
                                const Text(
                                  'Artículos comprados:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppConstants.kSpaceXS),
                                ...order.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${item.nombreSnapshot} x${item.cantidad}'),
                                        Text(
                                            '\$${item.subtotal.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(height: AppConstants.kSpaceLG),

                                // Método de pago
                                Text(
                                    'Método de pago: ${order.payment.metodo.toUpperCase()}'),
                                const SizedBox(height: AppConstants.kSpaceMD),

                                // Cambiador de estado
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Estado de Pedido:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    DropdownButton<String>(
                                      value: order.estado,
                                      items: [
                                        'pendiente',
                                        'procesando',
                                        'enviado',
                                        'entregado',
                                        'cancelado'
                                      ].map((String val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(val.toUpperCase()),
                                        );
                                      }).toList(),
                                      onChanged: (newStatus) async {
                                        if (newStatus != null &&
                                            newStatus != order.estado) {
                                          final messenger = ScaffoldMessenger.of(context);
                                          final success = await adminProvider
                                              .updateOrderStatus(
                                            order.pedidoId,
                                            newStatus,
                                          );
                                          if (mounted) {
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(success
                                                    ? 'Estado del pedido actualizado con éxito.'
                                                    : 'Error al cambiar estado.'),
                                                backgroundColor: success
                                                    ? AppColors.success
                                                    : AppColors.error,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
