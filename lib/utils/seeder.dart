import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;
    debugPrint('Iniciando seeder...');

    // Categorias
    final catBolsos = firestore.collection('categories').doc();
    final catZapatos = firestore.collection('categories').doc();
    final catRopa = firestore.collection('categories').doc();

    await catBolsos.set({
      'catId': catBolsos.id,
      'nombre': 'Bolsos',
      'slug': 'bolsos',
      'iconUrl': 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?w=400',
      'displayOrder': 1,
      'productCount': 2,
    });

    await catZapatos.set({
      'catId': catZapatos.id,
      'nombre': 'Zapatos',
      'slug': 'zapatos',
      'iconUrl': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400',
      'displayOrder': 2,
      'productCount': 1,
    });

    await catRopa.set({
      'catId': catRopa.id,
      'nombre': 'Ropa',
      'slug': 'ropa',
      'iconUrl': 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=400',
      'displayOrder': 3,
      'productCount': 1,
    });

    // Marcas
    final brandGucci = firestore.collection('brands').doc();
    await brandGucci.set({
      'brandId': brandGucci.id,
      'nombre': 'Luxe Brand',
      'logoUrl': 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=400',
      'descripcion': 'Marca de lujo internacional.',
    });

    // Productos
    await firestore.collection('products').add({
      'nombre': 'Bolso de Cuero Elegante',
      'descripcion': 'Bolso 100% cuero genuino con acabados dorados.',
      'precio': 4500.0,
      'discountPrice': 3800.0,
      'categoriaId': catBolsos.id,
      'categoriaNombre': 'Bolsos',
      'marcaId': brandGucci.id,
      'marcaNombre': 'Luxe Brand',
      'imagenes': [
        'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?w=800',
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800'
      ],
      'stock': 15,
      'rating': 4.8,
      'reviewCount': 24,
      'isPremium': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'variants': [
        {'sku': 'BOL-CUE-NE-M', 'talla': 'Única', 'color': 'Negro', 'colorHex': '#000000', 'stock': 10},
        {'sku': 'BOL-CUE-RO-M', 'talla': 'Única', 'color': 'Rojo', 'colorHex': '#8B0000', 'stock': 5},
      ]
    });

    await firestore.collection('products').add({
      'nombre': 'Vestido de Noche Estrellado',
      'descripcion': 'Vestido largo para eventos de gala.',
      'precio': 8900.0,
      'discountPrice': null,
      'categoriaId': catRopa.id,
      'categoriaNombre': 'Ropa',
      'marcaId': brandGucci.id,
      'marcaNombre': 'Luxe Brand',
      'imagenes': [
        'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=800'
      ],
      'stock': 8,
      'rating': 5.0,
      'reviewCount': 12,
      'isPremium': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'variants': [
        {'sku': 'VES-EST-AZ-S', 'talla': 'S', 'color': 'Azul', 'colorHex': '#00008B', 'stock': 3},
        {'sku': 'VES-EST-AZ-M', 'talla': 'M', 'color': 'Azul', 'colorHex': '#00008B', 'stock': 5},
      ]
    });

    await firestore.collection('products').add({
      'nombre': 'Zapatos de Tacón Clásicos',
      'descripcion': 'Zapatos de salón de aguja con suela roja característica.',
      'precio': 12500.0,
      'discountPrice': null,
      'categoriaId': catZapatos.id,
      'categoriaNombre': 'Zapatos',
      'marcaId': brandGucci.id,
      'marcaNombre': 'Luxe Brand',
      'imagenes': [
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800'
      ],
      'stock': 20,
      'rating': 4.9,
      'reviewCount': 45,
      'isPremium': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'variants': [
        {'sku': 'ZAP-TAC-NE-24', 'talla': '24', 'color': 'Negro', 'colorHex': '#000000', 'stock': 10},
        {'sku': 'ZAP-TAC-NE-25', 'talla': '25', 'color': 'Negro', 'colorHex': '#000000', 'stock': 10},
      ]
    });

    await firestore.collection('products').add({
      'nombre': 'Bolso Tote Casual',
      'descripcion': 'Ideal para el día a día. Espacioso y elegante.',
      'precio': 2200.0,
      'discountPrice': 1800.0,
      'categoriaId': catBolsos.id,
      'categoriaNombre': 'Bolsos',
      'marcaId': null,
      'marcaNombre': null,
      'imagenes': [
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800'
      ],
      'stock': 30,
      'rating': 4.2,
      'reviewCount': 8,
      'isPremium': false,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'variants': [
        {'sku': 'BOL-TOT-BE-M', 'talla': 'Única', 'color': 'Beige', 'colorHex': '#F5F5DC', 'stock': 30},
      ]
    });

    // Banners
    await firestore.collection('banners').add({
      'imageUrl': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200',
      'redirectUrl': '/products',
      'isActive': true,
      'displayOrder': 1,
    });

    debugPrint('Seeder finalizado con éxito.');
  }
}
