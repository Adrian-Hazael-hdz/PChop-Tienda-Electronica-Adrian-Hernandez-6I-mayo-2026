import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        // Redirigir a Home y limpiar historial de navegación
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        // Mostrar mensaje de error si ocurre
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error de autenticación'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpaceLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado / Logo simulado
                const Icon(
                  Icons.computer,
                  size: 80,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(height: AppConstants.kSpaceMD),
                Text(
                  'PChop',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Tu tienda de electrónica favorita',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.kSpaceXL),

                // Formulario estilizado dentro de una Card premium
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
                        // Email Input
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

                        // Password Input
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

                        // Botón de Inicio de Sesión
                        authProvider.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppConstants.kSpaceXS),
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Iniciar sesión'),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.kSpaceLG),

                // Enlace de Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    GestureDetector(
                      onTap: () {
                        authProvider.clearError();
                        Navigator.pushNamed(context, Routes.register);
                      },
                      child: const Text(
                        'Regístrate',
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
