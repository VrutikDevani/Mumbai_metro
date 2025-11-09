class ShiftHouseModel {
  String selectedDate;
  String selectedTime;
  String houseType;
  Map<String, int> itemCounts;

  ShiftHouseModel({
    this.selectedDate = '',
    this.selectedTime = '',
    this.houseType = '',
    Map<String, int>? itemCounts,
  }) : itemCounts = itemCounts ?? {};

  ShiftHouseModel copyWith({
    String? selectedDate,
    String? selectedTime,
    String? houseType,
    Map<String, int>? itemCounts,
  }) {
    return ShiftHouseModel(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      houseType: houseType ?? this.houseType,
      itemCounts: itemCounts ?? this.itemCounts,
    );
  }
}
