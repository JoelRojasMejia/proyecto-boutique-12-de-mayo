import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double minPurchase;
  final int maxUses;
  final int usedCount;
  final DateTime? expiresAt;
  final bool isActive;

  CouponModel({
    required this.code,
    required this.type,
    required this.value,
    required this.minPurchase,
    required this.maxUses,
    required this.usedCount,
    this.expiresAt,
    required this.isActive,
  });

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return CouponModel(
      code: data['code'] ?? doc.id,
      type: data['type'] ?? 'percentage',
      value: (data['value'] ?? 0).toDouble(),
      minPurchase: (data['minPurchase'] ?? 0).toDouble(),
      maxUses: data['maxUses'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'minPurchase': minPurchase,
      'maxUses': maxUses,
      'usedCount': usedCount,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'isActive': isActive,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isExhausted => usedCount >= maxUses;

  bool isValid(double subtotal) {
    return isActive && !isExpired && !isExhausted && subtotal >= minPurchase;
  }
}
