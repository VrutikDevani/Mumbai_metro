class ItemCategory {
  final String name;
  final String icon;
  final List<ItemDetail> items;

  ItemCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}

class ItemDetail {
  final String name;
  final int count;

  ItemDetail({
    required this.name,
    this.count = 0,
  });
}