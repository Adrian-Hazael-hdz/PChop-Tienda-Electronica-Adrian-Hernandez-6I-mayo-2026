import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../app/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<OrderProvider>().fetchOrders(user.uid);
        });
      }
      _initialized = true;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado.')),
      );
    }

    // Limitar a los últimos 5 pedidos
    final lastOrders = orderProvider.orders.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.kSpaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de perfil premium
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kBorderRadiusCard),
                side: const BorderSide(color: AppColors.divider),
              ),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.kSpaceLG),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        (authProvider.nombre ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.kSpaceLG),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.nombre ?? 'Usuario',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Miembro desde: ${_formatDate(authProvider.fechaRegistro)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.kSpaceMD),

            // Botones de acción
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.editProfile);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar Perfil'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.kBorderRadiusButton),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.kSpaceXL),

            // Título de pedidos recientes
            Text(
              'Pedidos Recientes (Últimos 5)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.kSpaceSM),

            // Lista de pedidos
            orderProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : lastOrders.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(AppConstants.kSpaceLG),
                        alignment: Alignment
                            .center, // Wait, CenterAlignment is not standard, let's use Alignment.center!
                        child: const Text(
                          'Aún no has realizado ningún pedido.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lastOrders.length,
                        itemBuilder: (context, index) {
                          final order = lastOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(
                                bottom: AppConstants.kSpaceSM),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kBorderRadiusThumbnail),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            child: ListTile(
                              title: Text(
                                  'Pedido #${order.pedidoId.substring(0, 8).toUpperCase()}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${_formatDate(order.fecha)}'),
                                  Text(
                                    'Estado: ${order.estado.toUpperCase()}',
                                    style: TextStyle(
                                      color: order.estado == 'pendiente'
                                          ? AppColors.warning.withRed(150)
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),

            const SizedBox(height: AppConstants.kSpaceXXL),

            // Botón Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, authProvider);
                },
                icon: const Icon(Icons.logout_outlined),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content:
            const Text('¿Estás seguro de que deseas salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.login, (route) => false);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
