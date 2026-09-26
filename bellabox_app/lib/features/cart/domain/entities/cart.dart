import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int id; // cart_item id
  final int productId;
  final int? variantId;
  final String name;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.name,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int? ?? product?['id'] as int? ?? 0,
      variantId: json['variant_id'] as int?,
      name: product?['name'] as String? ?? json['name'] as String? ?? '',
      imageUrl: product?['image'] as String? ??
          product?['main_image'] as String? ??
          json['image'] as String?,
      unitPrice: (json['price'] as num?)?.toDouble() ??
          (json['price_at_addition'] as num?)?.toDouble() ??
          0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, productId, variantId, quantity, unitPrice];
}

class Cart extends Equatable {
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final String? couponCode;

  const Cart({
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.shipping = 0,
    this.tax = 0,
    this.total = 0,
    this.couponCode,
  });

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List? ?? [])
        .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
        .toList();
    final totals = json['totals'] as Map<String, dynamic>? ?? json;
    return Cart(
      items: itemsList,
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
      couponCode: json['coupon_code'] as String? ??
          (json['coupon'] as Map<String, dynamic>?)?['code'] as String?,
    );
  }

  factory Cart.empty() => const Cart();

  @override
  List<Object?> get props => [items, subtotal, total, couponCode];
}
