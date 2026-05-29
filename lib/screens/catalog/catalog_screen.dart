import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/product_card.dart';
import '../../app/routes.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String? _selectedCategoryId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('categoryId')) {
        _selectedCategoryId = args['categoryId'] as String?;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CategoryProvider>().fetchAll();
        _loadProducts();
      });
      _initialized = true;
    }
  }

  void _loadProducts() {
    final productProvider = context.read<ProductProvider>();
    if (_selectedCategoryId != null) {
      productProvider.fetchByCategory(_selectedCategoryId!);
    } else {
      productProvider.fetchAll();
    }
  }

  void _selectCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
      ),
      body: Column(
        children: [
          // Selector de categorías horizontal
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: AppConstants.kSpaceSM),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.kSpaceMD),
              children: [
                // Opción "Todos"
                Padding(
                  padding: const EdgeInsets.only(right: AppConstants.kSpaceSM),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      if (selected) _selectCategory(null);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategoryId == null
                          ? AppColors.onPrimary
                          : AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Categorías de Firebase
                ...categoryProvider.categories.map((category) {
                  final isSelected = _selectedCategoryId == category.catId;
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: AppConstants.kSpaceSM),
                    child: ChoiceChip(
                      label: Text(category.nombre),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) _selectCategory(category.catId);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Grilla de productos
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : productProvider.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              productProvider.errorMessage!,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.kSpaceMD),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : productProvider.products.isEmpty
                        ? const Center(
                            child: Text(
                                'No hay productos disponibles en esta categoría.'),
                          )
                        : GridView.builder(
                            padding:
                                const EdgeInsets.all(AppConstants.kSpaceMD),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppConstants.kSpaceMD,
                              mainAxisSpacing: AppConstants.kSpaceMD,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = productProvider.products[index];
                              return ProductCard(product: product);
                            },
                          ),
          ),
        ],
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kBorderRadiusButton),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.kSpaceMD),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.cart);
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Carrito'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
