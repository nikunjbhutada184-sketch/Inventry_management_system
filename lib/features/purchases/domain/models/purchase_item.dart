import 'package:equatable/equatable.dart';
import '../../../../core/database/database_helper.dart';
import '../../../products/domain/models/product.dart';

class PurchaseItem extends Equatable {
  final String id;
  final String purchaseId;
  final String productId;
  final double qty;
  final double price; // Purchase price
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient property
  final Product? product;

  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.qty,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  double get total => qty * price;

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    double? qty,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    Product? product,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
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
      'purchase_id': purchaseId,
      'product_id': productId,
      'qty': qty,
      'price': price,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    return PurchaseItem(
      id: map['id'] as String,
      purchaseId: map['purchase_id'] as String,
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
        purchaseId,
        productId,
        qty,
        price,
        createdAt,
        updatedAt,
      ];
}
