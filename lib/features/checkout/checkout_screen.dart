import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/coupon_service.dart';
import '../../data/services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cpController = TextEditingController();
  final _couponController = TextEditingController();

  final CouponService _couponService = CouponService();
  final OrderService _orderService = OrderService();

  bool _isProcessing = false;
  bool _couponApplied = false;
  double _discount = 0;
  String? _couponCode;
  String? _couponError;
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    _calleController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    _cpController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _validateCoupon() async {
    final cart = context.read<CartProvider>().cart;
    if (cart == null) return;

    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _couponError = null;
      _couponApplied = false;
      _discount = 0;
      _couponCode = null;
    });

    try {
      final coupon = await _couponService.validateCoupon(code, cart.subtotal);
      final discount = _couponService.applyCoupon(coupon, cart.subtotal);
      setState(() {
        _discount = discount;
        _couponCode = code;
        _couponApplied = true;
      });
    } catch (e) {
      setState(() {
        _couponError = e.toString().replaceAll('Exception: ', '');
        _discount = 0;
        _couponCode = null;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _discount = 0;
      _couponCode = null;
      _couponError = null;
      _couponController.clear();
    });
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta de crédito/débito';
      case 'paypal':
        return 'PayPal';
      default:
        return '';
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un método de pago')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final cart = cartProvider.cart;

    if (cart == null || cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío')),
      );
      return;
    }

    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario no autenticado')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final orderId = await _orderService.confirmOrder(
        userId: authProvider.userModel!.uid,
        items: cart.items,
        direccionEnvio: {
          'calle': _calleController.text.trim(),
          'ciudad': _ciudadController.text.trim(),
          'estado': _estadoController.text.trim(),
          'pais': 'México',
          'codigoPostal': _cpController.text.trim(),
        },
        metodoPago: _selectedPaymentMethod!,
        subtotal: cart.subtotal,
        descuento: _discount,
        cuponUsado: _couponCode,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¡Pedido confirmado!',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu pedido #${orderId.substring(0, 8)} ha sido registrado.',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pago: ${_getPaymentMethodName()}',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/orders');
                  },
                  child: const Text('VER MIS PEDIDOS'),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        String msg = 'Error al procesar el pedido';
        if (e is Exception) {
          msg = e.toString().replaceFirst('Exception: ', '');
        } else if (e is FirebaseException) {
          msg = 'Error de Firestore: ${e.message}';
        } else {
          msg = e.toString();
        }
        debugPrint('CHECKOUT ERROR: $e');
        debugPrint('STACK TRACE: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final subtotal = cart?.subtotal ?? 0;
    final total = subtotal - _discount;
    final items = cart?.items ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart == null || items.isEmpty
          ? _buildEmptyCart(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Resumen del pedido'),
                    const SizedBox(height: 12),
                    _buildOrderItems(context, items, formatCurrency),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Dirección de envío'),
                    const SizedBox(height: 12),
                    _buildAddressForm(context),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Cupón de descuento'),
                    const SizedBox(height: 12),
                    _buildCouponSection(context),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Método de pago'),
                    const SizedBox(height: 12),
                    _buildPaymentMethods(context),
                    const SizedBox(height: 24),

                    _buildOrderSummary(context, subtotal, total, formatCurrency),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: _isProcessing
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _placeOrder,
                              child: const Text(
                                'CONFIRMAR PEDIDO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/products'),
            child: const Text('VER CATÁLOGO'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildOrderItems(
    BuildContext context,
    List items,
    NumberFormat formatCurrency,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: item.imagenUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imagenUrl,
                              fit: BoxFit.cover,
                              errorWidget: (ctx, url, err) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.image, size: 24),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image, size: 24),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombreSnapshot,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.talla} · ${item.color} · x${item.cantidad}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency.format(item.precioSnapshot * item.cantidad),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddressForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _calleController,
            decoration: const InputDecoration(
              labelText: 'Calle y número',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ciudadController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _estadoController,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cpController,
            decoration: const InputDecoration(
              labelText: 'Código postal',
              prefixIcon: Icon(Icons.mail_outlined),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_couponApplied) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cupón aplicado: $_couponCode',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Descuento: -${NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(_discount)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.success),
                    onPressed: _removeCoupon,
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: 'Código de cupón',
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                      errorText: _couponError,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onFieldSubmitted: (_) => _validateCoupon(),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _validateCoupon,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPaymentOption(
            context,
            value: 'efectivo',
            title: 'Efectivo',
            subtitle: 'Pago en efectivo al recibir',
            icon: Icons.payments_outlined,
          ),
          const Divider(height: 1),
          _buildPaymentOption(
            context,
            value: 'tarjeta',
            title: 'Tarjeta de crédito/débito',
            subtitle: 'Visa, Mastercard, AMEX',
            icon: Icons.credit_card_outlined,
          ),
          const Divider(height: 1),
          _buildPaymentOption(
            context,
            value: 'paypal',
            title: 'PayPal',
            subtitle: 'Pago seguro en línea',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    double subtotal,
    double total,
    NumberFormat formatCurrency,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            'Subtotal',
            formatCurrency.format(subtotal),
          ),
          if (_discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Descuento',
              '-${formatCurrency.format(_discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Envío',
            'Gratis',
            valueColor: AppColors.success,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatCurrency.format(total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: valueColor != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
