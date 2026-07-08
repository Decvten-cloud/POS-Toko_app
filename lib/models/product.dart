class Product {
  final int? id;
  final String name;
  final int sellingPrice;
  final int costPrice;
  final int stock;
  final String unit;
  final String category;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.sellingPrice,
    required this.costPrice,
    required this.stock,
    required this.unit,
    this.category = 'Lainnya',
    this.imagePath,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'stock': stock,
      'unit': unit,
      'category': category,
      'image_path': imagePath,
    };
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      sellingPrice: map['selling_price'] as int,
      costPrice: map['cost_price'] as int,
      stock: map['stock'] as int,
      unit: map['unit'] as String,
      category: map['category'] as String? ?? 'Lainnya',
      imagePath: map['image_path'] as String?,
    );
  }
}
