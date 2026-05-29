import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../app/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      nombre: _nombreController.text,
    );

    if (mounted) {
      if (success) {
        // Al registrar correctamente, el Auth Gate en app.dart detectará
        // el cambio de estado de sesión de Auth y enviará al usuario a HomeScreen.
        // Solo necesitamos limpiar la pantalla actual.
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error al registrar el usuario'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            authProvider.clearError();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpaceLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crea una cuenta',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Regístrate para comenzar a comprar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.kSpaceXL),

                // Card contenedor del formulario
                Container(
                  padding: const EdgeInsets.all(AppConstants.kSpaceLG),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Nombre
                        TextFormField(
                          controller: _nombreController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryDark),
                          ),
                          validator: (value) => Validators.validateRequired(value, 'nombre completo'),
                        ),
                        const SizedBox(height: AppConstants.kSpaceMD),

                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryDark),
                          ),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: AppConstants.kSpaceMD),

                        // Campo Contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryDark),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.onSurface,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: AppConstants.kSpaceLG),

                        // Botón SuccessButton "Registrar"
                        authProvider.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppConstants.kSpaceXS),
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: AppColors.onBackground,
                                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: AppColors.onBackground,
                                      ),
                                ),
                                child: const Text('Registrar'),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.kSpaceLG),

                // Link para volver a Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    GestureDetector(
                      onTap: () {
                        authProvider.clearError();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
