import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Registrados'),
      ),
      body: adminProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : adminProvider.users.isEmpty
              ? const Center(child: Text('No hay usuarios registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                  itemCount: adminProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = adminProvider.users[index];
                    final date = user['fechaRegistro'] as DateTime?;
                    final rol = user['rol'] as String;

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
                        leading: CircleAvatar(
                          backgroundColor: rol == 'admin'
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.disabled,
                          child: Icon(
                            rol == 'admin'
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: rol == 'admin'
                                ? AppColors.primaryDark
                                : AppColors.onSurface,
                          ),
                        ),
                        title: Text(
                          user['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email']),
                            const SizedBox(height: 2),
                            Text(
                              'Fecha de registro: ${_formatDate(date)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: rol == 'admin'
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.disabled.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rol.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: rol == 'admin'
                                  ? AppColors.primaryDark
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
