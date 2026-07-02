import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final double purchasePrice;
  final double sellingPrice;
  final double currentStock;
  final double minStock;
  final String? unit;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minStock,
    this.unit,
    this.description,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    double? purchasePrice,
    double? sellingPrice,
    double? currentStock,
    double? minStock,
    String? unit,
    String? description,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'min_stock': minStock,
      'unit': unit,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      categoryId: map['category_id'] as String?,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      currentStock: (map['current_stock'] as num).toDouble(),
      minStock: (map['min_stock'] as num).toDouble(),
      unit: map['unit'] as String?,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        barcode,
        categoryId,
        purchasePrice,
        sellingPrice,
        currentStock,
        minStock,
        unit,
        description,
        imagePath,
        createdAt,
        updatedAt,
      ];
}
