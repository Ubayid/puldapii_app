import 'dart:convert';

class ProductModel {
  final int id;
  final String name;
  final int price;
  final String description;
  final String? image;
  final String? imageUrl;

  final String badge;
  final String category;
  final int stock;
  final String stockStatus;
  final String condition;
  final String shippingArea;
  final String paymentMethod;
  final List<String> advantages;
  final String whatsapp;
  final String email;
  final String serviceHours;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.image,
    this.imageUrl,
    required this.badge,
    required this.category,
    required this.stock,
    required this.stockStatus,
    required this.condition,
    required this.shippingArea,
    required this.paymentMethod,
    required this.advantages,
    required this.whatsapp,
    required this.email,
    required this.serviceHours,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      price: _toInt(json['price']),
      description: _toString(json['description']),
      image: _toNullableString(json['image']),
      imageUrl: _toNullableString(json['image_url']),

      badge: _toString(json['badge']),
      category: _toString(json['category']),
      stock: _toInt(json['stock']),
      stockStatus: _toString(json['stock_status']),
      condition: _toString(json['condition']),
      shippingArea: _toString(json['shipping_area']),
      paymentMethod: _toString(json['payment_method']),
      advantages: _toListString(json['advantages']),
      whatsapp: _toString(json['whatsapp']),
      email: _toString(json['email']),
      serviceHours: _toString(json['service_hours']),
      isActive: _toBool(json['is_active']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') return '';

    return text;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') return null;

    return text;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value.toString().toLowerCase();

    return text == '1' || text == 'true';
  }

  static List<String> _toListString(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty && e != 'null')
          .toList();
    }

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty || text == 'null') return [];

      try {
        final decoded = jsonDecode(text);

        if (decoded is List) {
          return decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty && e != 'null')
              .toList();
        }
      } catch (_) {}

      return text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != 'null')
          .toList();
    }

    return [];
  }
}
