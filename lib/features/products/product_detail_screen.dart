import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/services/product_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  bool _isLoading = true;

  String? _selectedSize;
  String? _selectedColorHex;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _productService.getProductById(widget.productId);
    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
        if (product != null && product.variants.isNotEmpty) {
          _selectedSize = product.variants.first.talla;
          _selectedColorHex = product.variants.first.colorHex;
        }
      });
    }
  }

  ProductVariant? get _selectedVariant {
    if (_product == null || _selectedSize == null || _selectedColorHex == null) return null;
    return _product!.variants.cast<ProductVariant?>().firstWhere(
      (v) => v!.talla == _selectedSize && v.colorHex == _selectedColorHex,
      orElse: () => null,
    );
  }

  void _addToCart() {
    final variant = _selectedVariant;
    if (variant == null || _product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona talla y color')),
      );
      return;
    }

    if (variant.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta variante está agotada')),
      );
      return;
    }

    final cartItem = CartItemModel(
      prodId: _product!.id,
      sku: variant.sku,
      nombreSnapshot: _product!.nombre,
      precioSnapshot: _product!.hasDiscount ? _product!.discountPrice! : _product!.precio,
      talla: variant.talla,
      color: variant.color,
      colorHex: variant.colorHex,
      cantidad: 1,
      imagenUrl: _product!.imagenes.isNotEmpty ? _product!.imagenes.first : '',
    );

    context.read<CartProvider>().addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Añadido al carrito ✓')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final favoritesProvider = context.watch<FavoritesProvider>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Producto no encontrado')),
      );
    }

    final product = _product!;
    final sizes = product.variants.map((v) => v.talla).toSet().toList();
    final colors = product.variants
        .map((v) => {'color': v.color, 'hex': v.colorHex})
        .toSet()
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  favoritesProvider.isFavorite(product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoritesProvider.isFavorite(product.id)
                      ? AppColors.accentGold
                      : AppColors.textOnDark,
                ),
                onPressed: () => favoritesProvider.toggleFavorite(product.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: product.imagenes.isNotEmpty
                  ? PageView.builder(
                      itemCount: product.imagenes.length,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: product.imagenes[index],
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) =>
                              Container(color: AppColors.surfaceVariant),
                          errorWidget: (ctx, url, err) =>
                              const Icon(Icons.broken_image, size: 64),
                        );
                      },
                    )
                  : Container(color: AppColors.surfaceVariant),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image indicators
                  if (product.imagenes.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(product.imagenes.length, (i) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentImageIndex
                                ? AppColors.primary
                                : AppColors.textDisabled,
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: 16),

                  // Premium badge
                  if (product.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'EXCLUSIVO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.premiumBg,
                          letterSpacing: 1.5,
                          fontSize: 9,
                        ),
                      ),
                    ),

                  // Name
                  Text(product.nombre, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  if (product.marcaNombre != null)
                    Text(product.marcaNombre!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < product.rating.floor()
                              ? Icons.star
                              : (i < product.rating ? Icons.star_half : Icons.star_border),
                          color: AppColors.accentGold,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating} (${product.reviewCount} reseñas)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  if (product.hasDiscount)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency.format(product.discountPrice),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatCurrency.format(product.precio),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      formatCurrency.format(product.precio),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),

                  const Divider(height: 32),

                  // Size selector
                  Text('Talla', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: sizes.map((size) {
                      final selected = size == _selectedSize;
                      return ChoiceChip(
                        label: Text(size),
                        selected: selected,
                        onSelected: (val) => setState(() => _selectedSize = size),
                        selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                        side: BorderSide(
                          color: selected ? AppColors.primary : AppColors.divider,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Color selector
                  Text('Color', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: colors.map((c) {
                      final hex = c['hex'] as String;
                      final selected = hex == _selectedColorHex;
                      final colorValue = int.tryParse(hex.replaceAll('#', '0xFF')) ?? 0xFF999999;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorHex = hex),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.divider,
                              width: selected ? 3 : 1,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Stock info
                  if (_selectedVariant != null)
                    Text(
                      _selectedVariant!.stock > 0
                          ? '${_selectedVariant!.stock} en stock'
                          : 'Agotado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _selectedVariant!.stock > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),

                  const Divider(height: 32),

                  // Description
                  Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(product.descripcion, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('AÑADIR AL CARRITO'),
          ),
        ),
      ),
    );
  }
}
