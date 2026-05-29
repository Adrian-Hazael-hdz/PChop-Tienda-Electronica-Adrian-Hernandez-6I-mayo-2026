import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../data/services/seed_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/product_card.dart';
import '../../app/routes.dart';
import '../../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Poblar automáticamente la base de datos si está vacía
      await SeedData.seedDatabase();

      if (mounted) {
        // Cargar los productos destacados y categorías
        context.read<ProductProvider>().fetchFeatured();
        context.read<CategoryProvider>().fetchAll();

        // Cargar el carrito del usuario si está conectado
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.currentUser;
        if (user != null) {
          context.read<CartProvider>().fetchCart(user.uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('PChop'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, Routes.catalog);
            },
          ),
          // Icono del carrito con badge de cantidad
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              final itemCount = cartProvider.items.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.cart);
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.kSpaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de categorías rápidas
            Text(
              'Categorías',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: AppConstants.kSpaceMD),
            categoryProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : categoryProvider.categories.isEmpty
                    ? const Text('No hay categorías disponibles.')
                    : SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = categoryProvider.categories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.catalog,
                                  arguments: {'categoryId': category.catId},
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    right: AppConstants.kSpaceMD),
                                width: 70,
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      backgroundImage:
                                          NetworkImage(category.imagenUrl),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      category.nombre,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

            const SizedBox(height: AppConstants.kSpaceLG),

            // Sección de productos destacados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos Destacados',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.catalog);
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.kSpaceMD),

            productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : productProvider.errorMessage != null
                    ? Center(
                        child: Column(
                          children: [
                            Text(
                              productProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: AppConstants.kSpaceSM),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<ProductProvider>()
                                  .fetchFeatured(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : productProvider.featuredProducts.isEmpty
                        ? const Center(
                            child: Text('No hay productos destacados hoy.'))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppConstants.kSpaceMD,
                              mainAxisSpacing: AppConstants.kSpaceMD,
                              childAspectRatio: 0.75,
                            ),
                            itemCount:
                                productProvider.featuredProducts.length > 4
                                    ? 4
                                    : productProvider.featuredProducts.length,
                            itemBuilder: (context, index) {
                              final product =
                                  productProvider.featuredProducts[index];
                              return ProductCard(product: product);
                            },
                          ),
          ],
        ),
      ),
    );
  }
}
