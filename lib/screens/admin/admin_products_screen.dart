import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../app/routes.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
      ),
      body: adminProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : adminProvider.products.isEmpty
              ? const Center(child: Text('No hay productos registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                  itemCount: adminProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = adminProvider.products[index];
                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: AppConstants.kSpaceSM),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.kBorderRadiusThumbnail),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: AppColors.divider,
                            child: Image.network(
                              product.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) => const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: AppColors.primaryDark),
                            ),
                          ),
                        ),
                        title: Text(
                          product.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Precio: \$${product.precio.toStringAsFixed(2)} | Stock: ${product.stock}'),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.activo
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : AppColors.error.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.activo
                                    ? 'ACTIVO'
                                    : 'INACTIVO (Soft-Deleted)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: product.activo
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.primaryDark),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.adminProductsForm,
                                  arguments: {'id': product.prodId},
                                );
                              },
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: Icon(
                                product.activo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: product.activo
                                    ? Colors.redAccent
                                    : Colors.green,
                              ),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final success =
                                    await adminProvider.toggleProductActive(
                                  product.prodId,
                                  product.activo,
                                );
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Estado del producto actualizado.'
                                          : 'Error al actualizar estado.'),
                                    ),
                                  );
                                }
                              },
                              tooltip:
                                  product.activo ? 'Desactivar' : 'Activar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.adminProductsForm,
            arguments: {'id': ''}, // ID vacío indica creación
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
