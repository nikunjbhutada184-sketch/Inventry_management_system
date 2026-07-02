import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/category.dart';
import '../providers/category_providers.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  
  Color? _selectedColor;
  IconData? _selectedIcon;
  bool _isLoading = false;

  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  final List<IconData> _presetIcons = [
    Icons.folder,
    Icons.inventory_2,
    Icons.shopping_bag,
    Icons.fastfood,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.checkroom,
    Icons.devices,
    Icons.chair,
    Icons.toys,
    Icons.sports_esports,
    Icons.build,
    Icons.auto_awesome,
    Icons.pets,
    Icons.spa,
    Icons.brush,
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _descController = TextEditingController(text: c?.description ?? '');
    if (c?.color != null) {
      _selectedColor = Color(c!.color!);
    }
    if (c?.icon != null) {
      _selectedIcon = IconData(c!.icon!, fontFamily: 'MaterialIcons');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: _presetIcons.length,
            itemBuilder: (context, index) {
              final icon = _presetIcons[index];
              return IconButton(
                icon: Icon(icon, size: 32),
                color: _selectedIcon == icon ? Theme.of(context).colorScheme.primary : null,
                onPressed: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final category = Category(
        id: widget.category?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        color: _selectedColor?.value,
        icon: _selectedIcon?.codePoint,
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
      );

      final notifier = ref.read(categoriesProvider.notifier);
      if (widget.category == null) {
        await notifier.addCategory(category);
      } else {
        await notifier.updateCategory(category);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category saved successfully!')),
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.category != null;

    final displayColor = _selectedColor ?? colorScheme.primary;
    final displayIcon = _selectedIcon ?? Icons.folder;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Icon
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: displayColor.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(displayIcon, size: 48, color: displayColor),
                ),
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showIconPicker,
                      icon: const Icon(Icons.touch_app),
                      label: const Text('Choose Icon'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showColorPicker,
                      icon: const Icon(Icons.color_lens),
                      label: const Text('Choose Color'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              
              FilledButton(
                onPressed: _isLoading ? null : _saveForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
