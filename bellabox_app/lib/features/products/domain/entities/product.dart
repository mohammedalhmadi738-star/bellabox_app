import 'package:equatable/equatable.dart';

import 'package:bellabox/shared/widgets/cards/product_card.dart';

class Product extends Equatable {
  final int id;
  final String slug;
  final String name;
  final String? brandName;
  final int? brandId;
  final String? categoryName;
  final int? categoryId;
  final String? shortDescription;
  final String? description;
  final String? ingredients;
  final String? howToUse;
  final double price;
  final double? salePrice;
  final int stock;
  final bool isActive;
  final double ratingAvg;
  final int ratingCount;
  final List<String> images;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.slug,
    required this.name,
    this.brandName,
    this.brandId,
    this.categoryName,
    this.categoryId,
    this.shortDescription,
    this.description,
    this.ingredients,
    this.howToUse,
    required this.price,
    this.salePrice,
    this.stock = 0,
    this.isActive = true,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.images = const [],
    this.variants = const [],
  });

  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;
  bool get hasDiscount => salePrice != null && salePrice! < price;
  double get effectivePrice => salePrice ?? price;
  String? get mainImage => images.isNotEmpty ? images.first : null;

  ProductCardData toCardData() => ProductCardData(
        id: id,
        slug: slug,
        name: name,
        brand: brandName,
        imageUrl: mainImage,
        price: price,
        salePrice: salePrice,
        rating: ratingAvg,
        reviewCount: ratingCount,
        inStock: inStock,
      );

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic raw) {
      if (raw is List) {
        return raw
            .map((e) => e is Map<String, dynamic>
                ? (e['url'] as String? ?? '')
                : e.toString())
            .where((u) => u.isNotEmpty)
            .toList();
      }
      return const [];
    }

    return Product(
      id: json['id'] as int,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ??
          json['name_ar'] as String? ??
          json['name_en'] as String? ??
          '',
      brandName: json['brand'] is Map<String, dynamic>
          ? (json['brand']['name'] as String?)
          : json['brand_name'] as String?,
      brandId: json['brand'] is Map<String, dynamic>
          ? (json['brand']['id'] as int?)
          : json['brand_id'] as int?,
      categoryName: json['category'] is Map<String, dynamic>
          ? (json['category']['name'] as String?)
          : json['category_name'] as String?,
      categoryId: json['category'] is Map<String, dynamic>
          ? (json['category']['id'] as int?)
          : json['category_id'] as int?,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      ingredients: json['ingredients'] as String?,
      howToUse: json['how_to_use'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      stock: json['stock'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      images: parseImages(json['images']),
      variants: (json['variants'] as List?)
              ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [id, slug, name, price, salePrice, stock];
}

class ProductVariant extends Equatable {
  final int id;
  final String name;
  final double? price;
  final double? salePrice;
  final int stock;
  final String? image;
  final Map<String, dynamic> attributes;

  const ProductVariant({
    required this.id,
    required this.name,
    this.price,
    this.salePrice,
    this.stock = 0,
    this.image,
    this.attributes = const {},
  });

  bool get inStock => stock > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble(),
        salePrice: (json['sale_price'] as num?)?.toDouble(),
        stock: json['stock'] as int? ?? 0,
        image: json['image'] as String?,
        attributes: json['attributes'] as Map<String, dynamic>? ?? const {},
      );

  @override
  List<Object?> get props => [id, name, price, stock];
}

class Category extends Equatable {
  final int id;
  final String slug;
  final String name;
  final String? image;
  final String? icon;
  final int? parentId;
  final List<Category> children;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    this.image,
    this.icon,
    this.parentId,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ??
            json['name_ar'] as String? ??
            '',
        image: json['image'] as String?,
        icon: json['icon'] as String?,
        parentId: json['parent_id'] as int?,
        children: (json['children'] as List?)
                ?.map((c) => Category.fromJson(c as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [id, slug, name];
}

class Banner extends Equatable {
  final int id;
  final String? title;
  final String imageUrl;
  final String? linkType; // product | category | url
  final String? linkValue;

  const Banner({
    required this.id,
    this.title,
    required this.imageUrl,
    this.linkType,
    this.linkValue,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
        id: json['id'] as int,
        title: json['title'] as String?,
        imageUrl: json['image'] as String? ?? json['image_url'] as String? ?? '',
        linkType: json['link_type'] as String?,
        linkValue: json['link_value'] as String?,
      );

  @override
  List<Object?> get props => [id, imageUrl];
}
