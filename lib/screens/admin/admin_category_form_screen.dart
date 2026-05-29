import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/category_model.dart';
import '../../providers/admin_provider.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  const AdminCategoryFormScreen({super.key});

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _catId = '';
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  final _ordenController = TextEditingController();

  bool _initialized = false;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _catId = args['id'] as String;
      
      final adminProvider = context.read<AdminProvider>();

      if (_catId.isNotEmpty) {
        _isEditing = true;
        final category = adminProvider.categories.firstWhere(
          (c) => c.catId == _catId,
          orElse: () => CategoryModel(
            catId: '',
            nombre: '',
            descripcion: '',
            imagenUrl: '',
            orden: 0,
          ),
        );
        
        if (category.catId.isNotEmpty) {
          _nombreController.text = category.nombre;
          _descripcionController.text = category.descripcion;
          _imagenUrlController.text = category.imagenUrl;
          _ordenController.text = category.orden.toString();
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _imagenUrlController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final adminProvider = context.read<AdminProvider>();
    
    final category = CategoryModel(
      catId: _catId,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      imagenUrl: _imagenUrlController.text,
      orden: int.parse(_ordenController.text),
    );

    final success = await adminProvider.saveCategory(category);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Categoría guardada con éxito.' : adminProvider.errorMessage ?? 'Error al guardar.'),
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
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Categoría' : 'Agregar Categoría'),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.kSpaceMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.kSpaceLG),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusCard),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          // Nombre de la Categoría
                          TextFormField(
                            controller: _nombreController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la categoría',
                              prefixIcon: Icon(Icons.category_outlined, color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(value, 'nombre de la categoría'),
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          // Orden de visualización
                          TextFormField(
                            controller: _ordenController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Orden de despliegue',
                              prefixIcon: Icon(Icons.sort_outlined, color: AppColors.primaryDark),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requerido';
                              if (int.tryParse(value) == null) return 'Entero inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          // URL de Imagen
                          TextFormField(
                            controller: _imagenUrlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'URL de la imagen de categoría',
                              prefixIcon: Icon(Icons.image_outlined, color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(value, 'URL de la imagen'),
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descripción de la categoría',
                              prefixIcon: Icon(Icons.description_outlined, color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(value, 'descripción'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.kSpaceXL),

                    // Botones Guardar / Cancelar
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
                            onPressed: _submit,
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
