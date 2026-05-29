import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../app/routes.dart';
import '../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isAdmin = authProvider.rol == 'admin';

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            accountName: Text(
              authProvider.nombre ?? 'Usuario',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'usuario@correo.com',
              style: const TextStyle(
                color: AppColors.onPrimary,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppColors.onBackground),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, Routes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.onBackground),
            title: const Text('Catálogo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.catalog);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined, color: AppColors.onBackground),
            title: const Text('Categorías'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.categories);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined, color: AppColors.onBackground),
            title: const Text('Mi Carrito'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.cart);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.onBackground),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.onBackground),
            title: const Text('Contacto'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.contact);
            },
          ),
          
          // Panel Admin visible solo si tiene el rol de admin
          if (isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primaryDark),
              title: const Text(
                'Panel Administrador',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // La ruta del administrador se implementará en la Fase 5
                Navigator.pushNamed(context, '/admin-dashboard');
              },
            ),
          ],
          
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context, authProvider);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // cerrar el diálogo
              await authProvider.signOut();
              if (context.mounted) {
                // Limpiar todo el stack y redirigir al Login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
