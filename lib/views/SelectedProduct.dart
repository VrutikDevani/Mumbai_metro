class SelectedProduct {
  final String productName;
  int count;

  SelectedProduct({
    required this.productName,
    this.count = 0,
  });

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'count': count,
  };
}