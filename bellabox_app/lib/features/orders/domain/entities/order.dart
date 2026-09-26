import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromString(String? value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  bool get isCancellable =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.refunded;
}

class OrderItem extends Equatable {
  final int id;
  final String name;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final String? variantName;

  const OrderItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.variantName,
  });

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return OrderItem(
      id: json['id'] as int,
      name: json['product_name'] as String? ??
          product?['name'] as String? ??
          json['name'] as String? ??
          '',
      imageUrl: json['product_image'] as String? ??
          product?['image'] as String?,
      unitPrice: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      variantName: json['variant_name'] as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}

class Order extends Equatable {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final String? paymentMethod;
  final String? paymentStatus;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final Map<String, dynamic>? addressSnapshot;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.subtotal = 0,
    this.discount = 0,
    this.shipping = 0,
    this.tax = 0,
    this.total = 0,
    this.createdAt,
    this.items = const [],
    this.addressSnapshot,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? json;
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String?),
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
      subtotal: (totals['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (totals['discount_amount'] as num?)?.toDouble() ??
          (totals['discount'] as num?)?.toDouble() ??
          0,
      shipping: (totals['shipping_amount'] as num?)?.toDouble() ??
          (totals['shipping'] as num?)?.toDouble() ??
          0,
      tax: (totals['tax_amount'] as num?)?.toDouble() ??
          (totals['tax'] as num?)?.toDouble() ??
          0,
      total: (totals['total'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      items: (json['items'] as List?)
              ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      addressSnapshot: json['address'] as Map<String, dynamic>? ??
          json['shipping_address'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status];
}
