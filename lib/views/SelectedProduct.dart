class SelectedProduct {
  final String productName;
  int count;
  final int? productId; // Added
  final int? serviceId; // Added
  final int? productSubCatId; // Added

  SelectedProduct({
    required this.productName,
    this.count = 0,
    this.productId,
    this.serviceId,
    this.productSubCatId,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'count': count,
        'productId': productId, // Added
        'serviceId': serviceId, // Added
        'productSubCatId': productSubCatId, // Added
      };
}
