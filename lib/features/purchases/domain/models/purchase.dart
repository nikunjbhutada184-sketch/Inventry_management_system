import 'package:equatable/equatable.dart';
import '../../../../core/database/database_helper.dart';
import '../../../suppliers/domain/models/supplier.dart';
import 'purchase_item.dart';

class Purchase extends Equatable {
  final String id;
  final String? supplierId;
  final String? invoiceNumber;
  final DateTime date;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient properties
  final Supplier? supplier;
  final List<PurchaseItem>? items;

  const Purchase({
    required this.id,
    this.supplierId,
    this.invoiceNumber,
    required this.date,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.supplier,
    this.items,
  });

  Purchase copyWith({
    String? id,
    String? supplierId,
    String? invoiceNumber,
    DateTime? date,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Supplier? supplier,
    List<PurchaseItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supplier: supplier ?? this.supplier,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'invoice_number': invoiceNumber,
      'date': date.millisecondsSinceEpoch,
      'total': total,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map, {Supplier? supplier, List<PurchaseItem>? items}) {
    return Purchase(
      id: map['id'] as String,
      supplierId: map['supplier_id'] as String?,
      invoiceNumber: map['invoice_number'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      supplier: supplier,
      items: items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        supplierId,
        invoiceNumber,
        date,
        total,
        status,
        createdAt,
        updatedAt,
      ];
}
