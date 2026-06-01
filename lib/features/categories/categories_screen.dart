import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Color _getCategoryColor(String slug) {
    switch (slug.toLowerCase()) {
      case 'vestidos':
      case 'ropa':
        return const Color(0xFFFFE8EC);
      case 'calzado':
      case 'zapatos':
        return const Color(0xFFFFF0F5);
      case 'bolsos':
        return const Color(0xFFF0EBFF);
      case 'joyeria':
      case 'joyería':
        return const Color(0xFFFFF9DB);
      case 'abrigos':
        return const Color(0xFFE3F2FD);
      case 'accesorios':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'vestidos':
      case 'ropa':
        return Icons.checkroom;
      case 'calzado':
      case 'zapatos':
        return Icons.roller_skating; // or custom icon, e.g. shoe-like icon
      case 'bolsos':
        return Icons.shopping_bag;
      case 'joyeria':
      case 'joyería':
        return Icons.diamond;
      case 'abrigos':
        return Icons.layers;
      case 'accesorios':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        centerTitle: true,
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final bgColor = _getCategoryColor(category.slug);
                final icon = _getCategoryIcon(category.slug);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => context.push('/products?category=${category.catId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: bgColor,
                            child: Center(
                              child: category.iconUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: category.iconUrl,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) => Icon(icon, size: 48, color: AppColors.primary),
                                    )
                                  : Icon(icon, size: 48, color: AppColors.primary),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category.nombre,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${category.productCount} productos',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textDisabled,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
