import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ItemCategory.dart';
import '../models/shift_house_model.dart';
import '../views/SelectedProduct.dart';

class ShiftHouseViewModel extends ChangeNotifier {
  ShiftHouseModel _shiftHouseData = ShiftHouseModel();

  ShiftHouseModel get shiftHouseData => _shiftHouseData;

  final List<String> timeSlots = [
    '8:00 AM - 10:00 AM',
    '1:00 PM - 3:00 PM',
    '5:00 PM - 7:00 PM',
  ];

  final List<String> houseTypes = [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '1 RK',
    'Studio Apt.',
  ];

  final List<ItemCategory> itemCategories = [
    ItemCategory(
      name: 'ELECTRONICS APPLIANCES',
      icon: '📺',
      items: [
        ItemDetail(name: 'LCD/LED BELOW 40"'),
        ItemDetail(name: 'LCD/LED 42" - 50"'),
        ItemDetail(name: 'LCD/LED ABOVE 52"'),
        ItemDetail(name: 'CRT / BOX TV'),
        ItemDetail(name: 'SINGLE DOOR FRIDGE'),
        ItemDetail(name: 'DOUBLE DOOR FRIDGE'),
        ItemDetail(name: 'DUAL DOOR FRIDGE >400 ltr'),
        ItemDetail(name: 'WASHING MACHINE'),
        ItemDetail(name: 'WASHING MACHINE (FRONT LOAD)'),
        ItemDetail(name: 'DISH WASHER'),
        ItemDetail(name: 'DRYER MACHINE'),
        ItemDetail(name: 'MICROWAVE / OTG'),
        ItemDetail(name: 'WINDOW AC'),
        ItemDetail(name: 'SPLIT AC'),
        ItemDetail(name: 'AIR COOLER'),
        ItemDetail(name: 'TABLE / CEILING FAN'),
        ItemDetail(name: 'PEDESTAL FAN'),
        ItemDetail(name: 'WATER PURIFIER'),
        ItemDetail(name: 'COMPUTER SET'),
        ItemDetail(name: 'PRINTER'),
        ItemDetail(name: 'VACUUM CLEANER'),
        ItemDetail(name: 'MUSIC SYSTEM'),
        ItemDetail(name: 'TOASTER'),
        ItemDetail(name: 'MIXER/WET GRINDER'),
        ItemDetail(name: 'COFFEE MAKER'),
        ItemDetail(name: 'GEYSER / WATER HEATER'),
        ItemDetail(name: 'DTH'),
        ItemDetail(name: 'LAMP'),
        ItemDetail(name: 'INVERTER / UPS')
      ],
    ),
    ItemCategory(
      name: 'BED & BEDDING',
      icon: '🛏️',
      items: [
        ItemDetail(name: 'BED KING SIZE'),
        ItemDetail(name: 'BED QUEEN SIZE'),
        ItemDetail(name: 'BED (SINGLE SIZE)'),
        ItemDetail(name: 'BED (DOUBLE SIZE)'),
        ItemDetail(name: 'BOX BED'),
        ItemDetail(name: 'METAL BED'),
        ItemDetail(name: 'BUNK BED'),
        ItemDetail(name: 'DIWAN'),
        ItemDetail(name: 'SINGLE BED FOLDABLE'),
        ItemDetail(name: 'MATTRESS'),
        ItemDetail(name: 'SINGLE BED NON FOLDABLE'),
        ItemDetail(name: 'MATTRESS'),
        ItemDetail(name: 'DOUBLE BED FOLDABLE'),
        ItemDetail(name: 'MATTRESS')
      ],
    ),
    ItemCategory(
      name: 'SOFA & SEATING',
      icon: '🛋️',
      items: [
        ItemDetail(name: 'SOFA 1-SEATER'),
        ItemDetail(name: 'SOFA 2-SEATER'),
        ItemDetail(name: 'SOFA 3-SEATER'),
        ItemDetail(name: 'SOFA CUM BED'),
        ItemDetail(name: 'SOFA L SHAPE'),
        ItemDetail(name: 'SOFA (RECLINER)'),
        ItemDetail(name: 'DINING CHAIR'),
        ItemDetail(name: 'JHULA / SWING'),
        ItemDetail(name: 'Plastic Chair'),
        ItemDetail(name: 'Study Chair'),
        ItemDetail(name: 'Office Chair'),
        ItemDetail(name: 'Bean Bag'),
        ItemDetail(name: 'Pouf Chair')
      ],
    ),
    ItemCategory(
      name: 'WARDROBE & CABINET',
      icon: '🚪',
      items: [
        ItemDetail(name: 'WARDROBE (1 DOOR)'),
        ItemDetail(name: 'WARDROBE (2 DOOR)'),
        ItemDetail(name: 'WARDROBE (3 DOOR)'),
        ItemDetail(name: 'WARDROBE (4 DOOR)'),
        ItemDetail(name: 'CHEST OF DRAWER (SMALL)'),
        ItemDetail(name: 'CHEST OF DRAWER (MEDIUM)'),
        ItemDetail(name: 'CHEST OF DRAWER (LARGE)'),
        ItemDetail(name: 'SHOE CABINET'),
        ItemDetail(name: 'TV CABINET'),
        ItemDetail(name: 'Metal Almirah / Cupboard'),
        ItemDetail(name: 'SHOE CABINET'),
        ItemDetail(name: 'TV CABINET'),
        ItemDetail(name: 'Metal Almirah / Cupboard (Small)'),
        ItemDetail(name: 'Metal Almirah / Cupboard (Large)'),
        ItemDetail(name: 'Plastic Cupboard'),
        ItemDetail(name: 'DISPLAY UNIT (SMALL)'),
        ItemDetail(name: 'DISPLAY UNIT (LARGE)'),
        ItemDetail(name: 'TV UNIT (SMALL)'),
        ItemDetail(name: 'TV UNIT (LARGE)'),
        ItemDetail(name: 'SAFE / TIJORI')],
    ),
    ItemCategory(
      name: 'TABLE',
      icon: '',
      items: [
        ItemDetail(name: 'SIDE TABLE'),
        ItemDetail(name: 'CENTER TABLE'),
        ItemDetail(name: 'COFFEE TABLE'),
        ItemDetail(name: 'SUITCASE'),
        ItemDetail(name: 'COMPUTER STUDY TABLE'),
        ItemDetail(name: 'PLASTIC TABLE'),
        ItemDetail(name: 'DRESSING TABLE'),],
    ),
    ItemCategory(
      name: 'OTHER INVENTORIES',
      icon: '📦',
      items: [ ItemDetail(name: 'GAS STOVE'),
        ItemDetail(name: 'TEMPLE'),
        ItemDetail(name: 'SHOE RACE'),
        ItemDetail(name: 'BOOK SHELF(SMALL)'),
        ItemDetail(name: 'BOOK SHELF(LARGE)'),
        ItemDetail(name: 'CLOTH STAND'),
        ItemDetail(name: 'KITCHEN RACK'),
        ItemDetail(name: 'KIDS BICYCLE/SCOOTER'),
        ItemDetail(name: 'MIRROR'),
        ItemDetail(name: 'SEWING MACHINE'),
        ItemDetail(name: 'PAINTINGS/PHOTO FRAME(SMALL)'),],
    ),
    ItemCategory(
      name: 'BOXES & TROLLEY',
      icon: '📦',
      items: [
        ItemDetail(name: 'BOXES FOR KITCHEN'),
        ItemDetail(name: 'BOXES FOR CLOTHES'),
        ItemDetail(name: 'BOXES FOR BOOKS'),
        ItemDetail(name: 'BOXES FOR MISC. ITEMS'),
        ItemDetail(name: 'SMALL TROLLEY BAG'),
        ItemDetail(name: 'LARGE TROLLEY BAG'),
        ItemDetail(name: 'SUITCASE'),
        ItemDetail(name: 'METAL TRUNK'),
        ItemDetail(name: 'SMALL TRAVEL BAG'),
        ItemDetail(name: 'LARGE TRAVEL BAG'),
      ],
    ),
    ItemCategory(
      name: 'VEHICLES',
      icon: '🚗',
      items: [ ItemDetail(name: 'SCOOTY'),
        ItemDetail(name: 'BIKE <= 200 CC'),
        ItemDetail(name: 'BIKE > 200 CC AND <= 350 CC'),
        ItemDetail(name: 'LUXURY BIKE (E.G., HARLEY DAVIDSON)'),
        ItemDetail(name: 'EBike'),
        ItemDetail(name: 'HATCHBACK CAR'),
        ItemDetail(name: 'SEDAN CAR'),
        ItemDetail(name: 'JEEP'),
        ItemDetail(name: 'SUV / MUV'),],
    ),
    ItemCategory(
      name: 'Office Items',
      icon: '',
      items: [ ItemDetail(name: 'Laptop'),
      ],
    ),
  ];

  void updateDate(String date) {
    _shiftHouseData = _shiftHouseData.copyWith(selectedDate: date);
    notifyListeners();
  }

  void updateTime(String time) {
    _shiftHouseData = _shiftHouseData.copyWith(selectedTime: time);
    notifyListeners();
  }

  void updateHouseType(String houseType) {
    _shiftHouseData = _shiftHouseData.copyWith(houseType: houseType);
    notifyListeners();
  }

  void updateItemCount(String itemName, int count) {
    if (count < 0) return;

    Map<String, int> updatedCounts = Map.from(_shiftHouseData.itemCounts);
    updatedCounts[itemName] = count;
    _shiftHouseData = _shiftHouseData.copyWith(itemCounts: updatedCounts);
    notifyListeners();
  }

  void incrementItem(String itemName) {
    int currentCount = _shiftHouseData.itemCounts[itemName] ?? 0;
    updateItemCount(itemName, currentCount + 1);
  }

  void decrementItem(String itemName) {
    int currentCount = _shiftHouseData.itemCounts[itemName] ?? 0;
    if (currentCount > 0) {
      updateItemCount(itemName, currentCount - 1);
    }
  }

  int getItemCount(String itemName) {
    return _shiftHouseData.itemCounts[itemName] ?? 0;
  }

  int getTotalItemsInCategory(String categoryName) {
    ItemCategory? category = itemCategories.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => ItemCategory(name: '', icon: '', items: []),
    );

    int total = 0;
    for (var item in category.items) {
      total += getItemCount(item.name);
    }
    return total;
  }

  // New method to get selected products
  List<SelectedProduct> getSelectedProducts() {
    List<SelectedProduct> selectedProducts = [];
    for (var entry in _shiftHouseData.itemCounts.entries) {
      if (entry.value > 0) {
        selectedProducts.add(SelectedProduct(productName: entry.key, count: entry.value));
      }
    }
    return selectedProducts;
  }
}