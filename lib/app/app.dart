import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/admin_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/product_detail/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/admin_product_form_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_category_form_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import 'routes.dart';

/// Clave global del Navigator para poder navegar desde fuera del árbol de widgets.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listener global de autenticación que vive en MyApp (siempre en el árbol).
    // Cuando el usuario cierra sesión, navega al Login limpiando todo el stack.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // addPostFrameCallback garantiza que el Navigator ya esté montado.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.login,
            (route) => false,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'PChop',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: const AuthGate(),
        routes: {
          Routes.login:                (context) => const LoginScreen(),
          Routes.register:             (context) => const RegisterScreen(),
          Routes.home:                 (context) => const HomeScreen(),
          Routes.catalog:              (context) => const CatalogScreen(),
          Routes.categories:           (context) => const CategoriesScreen(),
          Routes.detail:               (context) => const ProductDetailScreen(),
          Routes.cart:                 (context) => const CartScreen(),
          Routes.checkout:             (context) => const CheckoutScreen(),
          Routes.profile:              (context) => const ProfileScreen(),
          Routes.editProfile:          (context) => const EditProfileScreen(),
          Routes.contact:              (context) => const ContactScreen(),
          Routes.adminDashboard:       (context) => const AdminDashboardScreen(),
          Routes.adminProducts:        (context) => const AdminProductsScreen(),
          Routes.adminProductsForm:    (context) => const AdminProductFormScreen(),
          Routes.adminCategories:      (context) => const AdminCategoriesScreen(),
          Routes.adminCategoriesForm:  (context) => const AdminCategoryFormScreen(),
          Routes.adminUsers:           (context) => const AdminUsersScreen(),
          Routes.adminOrders:          (context) => const AdminOrdersScreen(),
        },
      ),
    );
  }
}

/// Pantalla de transición que evalúa si el usuario está autenticado
/// y redirige a la pantalla correcta usando el navigator global.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Evaluar el estado inicial de autenticación una vez montado el widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        navigatorKey.currentState?.pushReplacementNamed(Routes.home);
      } else {
        navigatorKey.currentState?.pushReplacementNamed(Routes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga mientras se evalúa el estado de autenticación.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
