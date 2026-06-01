import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/shimmer_product_card.dart';
import '../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategoryId;

  const ProductsScreen({super.key, this.initialCategoryId});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedCategoryId;
  String _sortOption = 'none'; // 'none', 'price_asc', 'price_desc', 'rating'
  bool _onlyPremium = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void didUpdateWidget(covariant ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryId != oldWidget.initialCategoryId) {
      setState(() {
        _selectedCategoryId = widget.initialCategoryId;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _sortOption = 'none';
      _onlyPremium = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();

    // ── FILTERING & SORTING LOGIC ──────────────────────────────────────
    List<dynamic> filteredProducts = List.from(productProvider.products);

    if (_selectedCategoryId != null) {
      filteredProducts = filteredProducts.where((p) => p.categoriaId == _selectedCategoryId).toList();
    }

    if (_onlyPremium) {
      filteredProducts = filteredProducts.where((p) => p.isPremium).toList();
    }

    if (_sortOption == 'price_asc') {
      filteredProducts.sort((a, b) {
        final priceA = a.hasDiscount ? a.discountPrice! : a.precio;
        final priceB = b.hasDiscount ? b.discountPrice! : b.precio;
        return priceA.compareTo(priceB);
      });
    } else if (_sortOption == 'price_desc') {
      filteredProducts.sort((a, b) {
        final priceA = a.hasDiscount ? a.discountPrice! : a.precio;
        final priceB = b.hasDiscount ? b.discountPrice! : b.precio;
        return priceB.compareTo(priceA);
      });
    } else if (_sortOption == 'rating') {
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Catálogo'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      // ── HAMBURGER MENU (NAVIGATION DRAWER) ────────────────────────
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aztro Boutique',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Moda exclusiva al alcance de tu mano',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Inicio'),
              onTap: () {
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Catálogo Completo'),
              onTap: () {
                _resetFilters();
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Mi Carrito'),
              onTap: () {
                context.go('/cart');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favoritos'),
              onTap: () {
                context.push('/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Mis Pedidos'),
              onTap: () {
                context.push('/orders');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mi Perfil'),
              onTap: () {
                context.go('/profile');
              },
            ),
          ],
        ),
      ),
      // ── FILTER DRAWER (END DRAWER) ──────────────────────────────────
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtros y Orden',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories section
                        Text(
                          'Categorías',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Todas'),
                              selected: _selectedCategoryId == null,
                              onSelected: (val) {
                                if (val) {
                                  setState(() => _selectedCategoryId = null);
                                }
                              },
                              selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                              side: BorderSide(
                                color: _selectedCategoryId == null ? AppColors.primary : AppColors.divider,
                              ),
                            ),
                            ...productProvider.categories.map((category) {
                              final selected = _selectedCategoryId == category.catId;
                              return ChoiceChip(
                                avatar: ClipOval(
                                  child: category.iconUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: category.iconUrl,
                                          width: 18,
                                          height: 18,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => const Icon(Icons.category, size: 14),
                                        )
                                      : const Icon(Icons.category, size: 14),
                                ),
                                label: Text(category.nombre),
                                selected: selected,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() => _selectedCategoryId = category.catId);
                                  }
                                },
                                selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                                side: BorderSide(
                                  color: selected ? AppColors.primary : AppColors.divider,
                                ),
                              );
                            }),
                          ],
                        ),
                        const Divider(height: 40),

                        // Exclusive filter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Solo Premium',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Mostrar productos exclusivos',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Switch(
                              value: _onlyPremium,
                              onChanged: (val) {
                                setState(() => _onlyPremium = val);
                              },
                              activeThumbColor: AppColors.accentGold,
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Sorting section
                        Text(
                          'Ordenar Por',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Lo más nuevo (Default)'),
                          leading: Icon(
                            _sortOption == 'none'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: _sortOption == 'none' ? AppColors.primary : AppColors.textDisabled,
                          ),
                          onTap: () => setState(() => _sortOption = 'none'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Precio: de menor a mayor'),
                          leading: Icon(
                            _sortOption == 'price_asc'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: _sortOption == 'price_asc' ? AppColors.primary : AppColors.textDisabled,
                          ),
                          onTap: () => setState(() => _sortOption = 'price_asc'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Precio: de mayor a menor'),
                          leading: Icon(
                            _sortOption == 'price_desc'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: _sortOption == 'price_desc' ? AppColors.primary : AppColors.textDisabled,
                          ),
                          onTap: () => setState(() => _sortOption = 'price_desc'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mejor Calificación'),
                          leading: Icon(
                            _sortOption == 'rating'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: _sortOption == 'rating' ? AppColors.primary : AppColors.textDisabled,
                          ),
                          onTap: () => setState(() => _sortOption = 'rating'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('LIMPIAR FILTROS'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('APLICAR'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (!productProvider.isLoading)
            Container(
              height: 56,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: productProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final selected = _selectedCategoryId == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: const Text('Todos'),
                        selected: selected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategoryId = null);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final category = productProvider.categories[index - 1];
                  final selected = _selectedCategoryId == category.catId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category.nombre),
                      selected: selected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategoryId = category.catId);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: productProvider.isLoading
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerProductCard(),
                  )
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.filter_list_off, size: 72, color: AppColors.textDisabled),
                            const SizedBox(height: 16),
                            Text(
                              'Sin resultados',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prueba ajustando tus filtros de búsqueda.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: _resetFilters,
                              child: const Text('RESTABLECER FILTROS'),
                            ),
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
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            isFavorite: favoritesProvider.isFavorite(product.id),
                            onTap: () => context.push('/products/${product.id}'),
                            onWishlistToggle: () => favoritesProvider.toggleFavorite(product.id),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
