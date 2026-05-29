import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../app/routes.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Categorías'),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : adminProvider.categories.isEmpty
              ? const Center(child: Text('No hay categorías registradas.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                  itemCount: adminProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = adminProvider.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppConstants.kSpaceSM),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusThumbnail),
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
                              category.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) =>
                                  const Icon(Icons.category_outlined, color: AppColors.primaryDark),
                            ),
                          ),
                        ),
                        title: Text(
                          category.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Orden: ${category.orden} | ${category.descripcion}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.adminCategoriesForm,
                              arguments: {'id': category.catId},
                            );
                          },
                          tooltip: 'Editar',
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.adminCategoriesForm,
            arguments: {'id': ''}, // Creación
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
