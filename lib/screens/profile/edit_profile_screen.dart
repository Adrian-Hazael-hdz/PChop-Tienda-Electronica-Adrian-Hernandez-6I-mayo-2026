import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = context.read<AuthProvider>();
      _nombreController = TextEditingController(text: authProvider.nombre);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    final success = await authProvider.updateProfile(user.uid, _nombreController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Perfil actualizado con éxito.' : authProvider.errorMessage ?? 'Error al guardar.'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.kSpaceMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mensaje informativo
                    const Text(
                      'Modifica los datos de tu cuenta personal.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: AppConstants.kSpaceMD),

                    // Card del Formulario
                    Container(
                      padding: const EdgeInsets.all(AppConstants.kSpaceLG),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre Completo
                          TextFormField(
                            controller: _nombreController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(value, 'nombre completo'),
                          ),
                          const SizedBox(height: AppConstants.kSpaceLG),

                          // Correo Electrónico (No editable)
                          TextFormField(
                            initialValue: user?.email ?? '',
                            enabled: false, // Inhabilitar edición
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico (No modificable)',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.disabled),
                              fillColor: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.kSpaceXL),

                    // Botones de guardar / cancelar
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusButton),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.kSpaceMD),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
