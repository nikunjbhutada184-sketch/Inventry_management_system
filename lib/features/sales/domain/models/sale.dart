import 'package:equatable/equatable.dart';
import '../../../customers/domain/models/customer.dart';
import 'sale_item.dart';

class Sale extends Equatable {
  final String id;
  final String? customerId;
  final String? invoiceNumber;
  final DateTime date;
  final double subtotal; // sum of item totals before discount/tax
  final double discount;
  final double tax;
  final double total; // final total
  final String? paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient properties
  final Customer? customer;
  final List<SaleItem>? items;

  const Sale({
    required this.id,
    this.customerId,
    this.invoiceNumber,
    required this.date,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.items,
  });

  Sale copyWith({
    String? id,
    String? customerId,
    String? invoiceNumber,
    DateTime? date,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Customer? customer,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'invoice_number': invoiceNumber,
      'date': date.millisecondsSinceEpoch,
      'total': total,
      'discount': discount,
      'tax': tax,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, {Customer? customer, List<SaleItem>? items}) {
    // Note: since subtotal is not saved directly, we compute it if items are present
    // or just default to total + discount - tax for a rough estimate if items are missing
    double computedSubtotal = 0;
    if (items != null) {
      for (var item in items) {
        computedSubtotal += item.total;
      }
    } else {
      computedSubtotal = (map['total'] as num).toDouble() + (map['discount'] as num).toDouble() - (map['tax'] as num).toDouble();
    }

    return Sale(
      id: map['id'] as String,
      customerId: map['customer_id'] as String?,
      invoiceNumber: map['invoice_number'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      subtotal: computedSubtotal,
      discount: (map['discount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      customer: customer,
      items: items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        invoiceNumber,
        date,
        subtotal,
        discount,
        tax,
        total,
        paymentMethod,
        status,
        createdAt,
        updatedAt,
      ];
}
