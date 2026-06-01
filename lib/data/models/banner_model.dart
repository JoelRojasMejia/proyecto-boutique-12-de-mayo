import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String bannerId;
  final String imageUrl;
  final String redirectUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int displayOrder;

  BannerModel({
    required this.bannerId,
    required this.imageUrl,
    required this.redirectUrl,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.displayOrder,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return BannerModel(
      bannerId: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      redirectUrl: data['redirectUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }
}
