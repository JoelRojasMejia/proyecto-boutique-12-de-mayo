import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CouponModel> validateCoupon(String code, double subtotal) async {
    final doc = await _firestore.collection('coupons').doc(code).get();

    if (!doc.exists) {
      throw Exception('Cupón inválido');
    }

    final coupon = CouponModel.fromFirestore(doc);

    if (!coupon.isActive) {
      throw Exception('Cupón desactivado');
    }

    if (coupon.isExpired) {
      throw Exception('Cupón expirado');
    }

    if (coupon.isExhausted) {
      throw Exception('Cupón agotado');
    }

    if (subtotal < coupon.minPurchase) {
      throw Exception('Mínimo de compra requerido: \$${coupon.minPurchase}');
    }

    return coupon;
  }

  double applyCoupon(CouponModel coupon, double subtotal) {
    if (coupon.type == 'percentage') {
      return subtotal * (coupon.value / 100);
    } else if (coupon.type == 'fixed') {
      return coupon.value < subtotal ? coupon.value : subtotal;
    }
    return 0;
  }
}
