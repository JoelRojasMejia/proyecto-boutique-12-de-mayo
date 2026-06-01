class CartItemModel {
  final String prodId;
  final String sku;
  final String nombreSnapshot;
  final double precioSnapshot;
  final String talla;
  final String color;
  final String colorHex;
  final int cantidad;
  final String imagenUrl;

  CartItemModel({
    required this.prodId,
    required this.sku,
    required this.nombreSnapshot,
    required this.precioSnapshot,
    required this.talla,
    required this.color,
    required this.colorHex,
    required this.cantidad,
    required this.imagenUrl,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      prodId: data['prodId'] ?? '',
      sku: data['sku'] ?? '',
      nombreSnapshot: data['nombreSnapshot'] ?? '',
      precioSnapshot: (data['precioSnapshot'] ?? 0).toDouble(),
      talla: data['talla'] ?? '',
      color: data['color'] ?? '',
      colorHex: data['colorHex'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prodId': prodId,
      'sku': sku,
      'nombreSnapshot': nombreSnapshot,
      'precioSnapshot': precioSnapshot,
      'talla': talla,
      'color': color,
      'colorHex': colorHex,
      'cantidad': cantidad,
      'imagenUrl': imagenUrl,
    };
  }

  Map<String, dynamic> toOrderMap() {
    return {
      'prodId': prodId,
      'sku': sku,
      'nombre': nombreSnapshot,
      'precioUnitario': precioSnapshot,
      'cantidad': cantidad,
      'talla': talla,
      'color': color,
      'imagenUrl': imagenUrl,
    };
  }
}
