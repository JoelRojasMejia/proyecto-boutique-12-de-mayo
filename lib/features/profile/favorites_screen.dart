import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';
import '../../shared/widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final productProvider = context.watch<ProductProvider>();

    final favoriteProducts = productProvider.products
        .where((p) => favoritesProvider.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 80, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text('Sin favoritos aún', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Toca el ❤️ en un producto para guardarlo aquí',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.52,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ProductCard(
                  product: product,
                  isFavorite: true,
                  onTap: () => context.push('/products/${product.id}'),
                  onWishlistToggle: () => favoritesProvider.toggleFavorite(product.id),
                );
              },
            ),
    );
  }
}
