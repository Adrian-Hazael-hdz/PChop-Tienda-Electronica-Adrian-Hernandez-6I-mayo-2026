import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../app/routes.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : categoryProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        categoryProvider.errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.kSpaceMD),
                      ElevatedButton(
                        onPressed: () => context.read<CategoryProvider>().fetchAll(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : categoryProvider.categories.isEmpty
                  ? const Center(child: Text('No hay categorías disponibles.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                      itemCount: categoryProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.kSpaceMD),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.catalog,
                                  arguments: {'categoryId': category.catId},
                                );
                              },
                              leading: Container(
                                width: 80,
                                height: 80,
                                color: AppColors.divider,
                                child: Image.network(
                                  category.imagenUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.category_outlined, color: AppColors.primaryDark),
                                    );
                                  },
                                ),
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(left: AppConstants.kSpaceMD, top: AppConstants.kSpaceSM),
                                child: Text(
                                  category.nombre,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: AppConstants.kSpaceMD, top: AppConstants.kSpaceXS, bottom: AppConstants.kSpaceSM),
                                child: Text(
                                  category.descripcion,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: const Padding(
                                padding: EdgeInsets.only(right: AppConstants.kSpaceMD),
                                child: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
