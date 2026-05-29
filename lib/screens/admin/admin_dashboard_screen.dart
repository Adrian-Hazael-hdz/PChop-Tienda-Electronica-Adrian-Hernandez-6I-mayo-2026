import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../app/routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      adminProvider.fetchProducts();
      adminProvider.fetchCategories();
      adminProvider.fetchUsers();
      adminProvider.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    // Protección de ruta reactiva
    if (authProvider.rol != 'admin') {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.kSpaceLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 72, color: AppColors.error),
                const SizedBox(height: AppConstants.kSpaceMD),
                Text(
                  'Acceso Restringido',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: AppConstants.kSpaceSM),
                const Text(
                  'Lo sentimos, solo los usuarios con rol de administrador pueden acceder a este panel.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.kSpaceXL),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, Routes.home);
                  },
                  child: const Text('Volver a Inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.home);
            },
            tooltip: 'Volver a tienda',
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.kSpaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Resumen de la tienda
                  Text(
                    'Resumen de actividad',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppConstants.kSpaceMD,
                    mainAxisSpacing: AppConstants.kSpaceMD,
                    childAspectRatio: 1.5,
                    children: [
                      _buildSummaryCard(
                        context,
                        'Productos',
                        '${adminProvider.products.length}',
                        Icons.shopping_bag_outlined,
                        AppColors.primary,
                      ),
                      _buildSummaryCard(
                        context,
                        'Categorías',
                        '${adminProvider.categories.length}',
                        Icons.category_outlined,
                        AppColors.secondary,
                      ),
                      _buildSummaryCard(
                        context,
                        'Usuarios',
                        '${adminProvider.users.length}',
                        Icons.people_outline,
                        AppColors.success,
                      ),
                      _buildSummaryCard(
                        context,
                        'Pedidos',
                        '${adminProvider.orders.length}',
                        Icons.receipt_long_outlined,
                        AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.kSpaceXL),

                  // Módulos CRUD
                  Text(
                    'Gestión de Módulos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.kSpaceSM),
                  _buildModuleTile(
                    context,
                    'Productos del Catálogo',
                    'Crear, editar, activar o desactivar productos.',
                    Icons.shopping_bag_outlined,
                    Routes.adminProducts,
                  ),
                  _buildModuleTile(
                    context,
                    'Categorías de la Tienda',
                    'Administrar grupos y orden de visualización.',
                    Icons.category_outlined,
                    Routes.adminCategories,
                  ),
                  _buildModuleTile(
                    context,
                    'Usuarios Registrados',
                    'Auditar cuentas y verificar roles de usuario.',
                    Icons.people_outline,
                    Routes.adminUsers,
                  ),
                  _buildModuleTile(
                    context,
                    'Pedidos Realizados',
                    'Controlar estados de envío, entrega y cancelaciones.',
                    Icons.receipt_long_outlined,
                    Routes.adminOrders,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
        side: const BorderSide(color: AppColors.divider),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpaceMD),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.onBackground,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.kSpaceSM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusThumbnail),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurface),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
