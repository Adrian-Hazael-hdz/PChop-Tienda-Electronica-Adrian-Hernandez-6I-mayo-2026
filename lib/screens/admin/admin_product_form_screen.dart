import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/product_model.dart';
import '../../providers/admin_provider.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _prodId = '';
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _destacado = false;
  bool _activo = true;
  DateTime _fechaCreacion = DateTime.now();

  bool _initialized = false;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _prodId = args['id'] as String;

      final adminProvider = context.read<AdminProvider>();

      // Diferir la carga al siguiente frame para evitar llamar
      // notifyListeners() durante la fase de build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AdminProvider>().fetchCategories();
        }
      });

      if (_prodId.isNotEmpty) {
        _isEditing = true;
        final product = adminProvider.products.firstWhere(
          (p) => p.prodId == _prodId,
          orElse: () => ProductModel(
            prodId: '',
            categoriaId: '',
            categoriaNombre: '',
            nombre: '',
            descripcion: '',
            precio: 0,
            stock: 0,
            imagenUrl: '',
            activo: true,
            destacado: false,
            fechaCreacion: DateTime.now(),
          ),
        );

        if (product.prodId.isNotEmpty) {
          _nombreController.text = product.nombre;
          _precioController.text = product.precio.toString();
          _stockController.text = product.stock.toString();
          _descripcionController.text = product.descripcion;
          _imagenUrlController.text = product.imagenUrl;
          _selectedCategoryId = product.categoriaId;
          _selectedCategoryName = product.categoriaNombre;
          _destacado = product.destacado;
          _activo = product.activo;
          _fechaCreacion = product.fechaCreacion;
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría.')),
      );
      return;
    }

    final adminProvider = context.read<AdminProvider>();

    // Obtener nombre de categoría para denormalización
    if (_selectedCategoryName == null) {
      final cat = adminProvider.categories
          .firstWhere((c) => c.catId == _selectedCategoryId);
      _selectedCategoryName = cat.nombre;
    }

    final product = ProductModel(
      prodId: _prodId,
      categoriaId: _selectedCategoryId!,
      categoriaNombre: _selectedCategoryName!,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      precio: double.parse(_precioController.text),
      stock: int.parse(_stockController.text),
      imagenUrl: _imagenUrlController.text,
      activo: _activo,
      destacado: _destacado,
      fechaCreacion: _fechaCreacion,
    );

    final success = await adminProvider.saveProduct(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Producto guardado con éxito.'
              : adminProvider.errorMessage ?? 'Error al guardar.'),
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
        title: Text(_isEditing ? 'Editar Producto' : 'Agregar Producto'),
      ),
      body: adminProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
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
                        borderRadius: BorderRadius.circular(
                            AppConstants.kBorderRadiusCard),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          // Nombre del Producto
                          TextFormField(
                            controller: _nombreController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del producto',
                              prefixIcon: Icon(Icons.shopping_bag_outlined,
                                  color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(
                                value, 'nombre del producto'),
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          // Categoría (Dropdown)
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              prefixIcon: Icon(Icons.category_outlined,
                                  color: AppColors.primaryDark),
                            ),
                            items: adminProvider.categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.catId,
                                child: Text(cat.nombre),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                                _selectedCategoryName =
                                    null; // Fuerza recarga del nombre
                              });
                            },
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          Row(
                            children: [
                              // Precio
                              Expanded(
                                child: TextFormField(
                                  controller: _precioController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Precio (\$)',
                                    prefixIcon: Icon(Icons.attach_money,
                                        color: AppColors.primaryDark),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Requerido';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Número inválido';
                                    }
                                    if (double.parse(value) < 0) {
                                      return 'Debe ser >= 0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: AppConstants.kSpaceMD),
                              // Stock
                              Expanded(
                                child: TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock (u.)',
                                    prefixIcon: Icon(Icons.inventory_2_outlined,
                                        color: AppColors.primaryDark),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Requerido';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Entero inválido';
                                    }
                                    if (int.parse(value) < 0) {
                                      return 'Debe ser >= 0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          // URL de Imagen
                          TextFormField(
                            controller: _imagenUrlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'URL de la imagen',
                              prefixIcon: Icon(Icons.image_outlined,
                                  color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(
                                value, 'URL de la imagen'),
                          ),
                          const SizedBox(height: AppConstants.kSpaceMD),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descripción del producto',
                              prefixIcon: Icon(Icons.description_outlined,
                                  color: AppColors.primaryDark),
                            ),
                            validator: (value) => Validators.validateRequired(
                                value, 'descripción'),
                          ),
                          const SizedBox(height: AppConstants.kSpaceLG),

                          // Interruptores (Destacado y Activo)
                          SwitchListTile(
                            title: const Text(
                                'Producto Destacado (Aparece en Home)'),
                            value: _destacado,
                            activeThumbColor: AppColors.primaryDark,
                            onChanged: (val) {
                              setState(() {
                                _destacado = val;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text(
                                'Producto Activo (Visible para clientes)'),
                            value: _activo,
                            activeThumbColor: AppColors.primaryDark,
                            onChanged: (val) {
                              setState(() {
                                _activo = val;
                              });
                            },
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
                                borderRadius: BorderRadius.circular(
                                    AppConstants.kBorderRadiusButton),
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
