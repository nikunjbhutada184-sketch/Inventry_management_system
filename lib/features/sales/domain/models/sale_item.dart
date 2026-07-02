import 'package:equatable/equatable.dart';
import '../../../products/domain/models/product.dart';

class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String productId;
  final double qty;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Transient property for UI displaying product details in the cart/invoice
  final Product? product;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.qty,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  double get total => qty * price;

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    double? qty,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    Product? product,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'qty': qty,
      'price': price,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    return SaleItem(
      id: map['id'] as String,
      saleId: map['sale_id'] as String,
      productId: map['product_id'] as String,
      qty: (map['qty'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      product: product,
    );
  }

  @override
  List<Object?> get props => [
        id,
        saleId,
        productId,
        qty,
        price,
        createdAt,
        updatedAt,
      ];
}
