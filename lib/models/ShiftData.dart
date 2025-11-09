import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../views/SelectedProduct.dart';

class ShiftData {
  final int serviceId;
  final String serviceName;
  String selectedDate;
  String selectedTime;
  List<SelectedProduct> selectedProducts;
  final int? customerId;

  // Additional fields for subcategory navigation
  int? subCategoryId;
  String? categoryBannerImg;
  String? categoryDesc;

  // Location related fields
  String? sourceAddress;
  String? destinationAddress;
  LatLng? sourceCoordinates;
  LatLng? destinationCoordinates;

  // Lift and floor information
  bool normalLiftSource = false;
  bool serviceLiftSource = false;
  int floorSource = 0;
  bool normalLiftDestination = false;
  bool serviceLiftDestination = false;
  int floorDestination = 0;

  ShiftData({
    required this.serviceId,
    required this.serviceName,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedProducts,
    this.customerId,
    this.subCategoryId,
    this.categoryBannerImg,
    this.categoryDesc,
    this.sourceAddress,
    this.destinationAddress,
    this.sourceCoordinates,
    this.destinationCoordinates,
    this.normalLiftSource = false,
    this.serviceLiftSource = false,
    this.floorSource = 0,
    this.normalLiftDestination = false,
    this.serviceLiftDestination = false,
    this.floorDestination = 0,
  });

  // Method to get total product count
  int getTotalProductCount() {
    return selectedProducts.fold(0, (sum, product) => sum + product.count);
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'selectedDate': selectedDate,
      'selectedTime': selectedTime,
      'selectedProducts': selectedProducts.map((p) => p.toJson()).toList(),
      'customerId': customerId,
      'subCategoryId': subCategoryId,
      'categoryBannerImg': categoryBannerImg,
      'categoryDesc': categoryDesc,
      'sourceAddress': sourceAddress,
      'destinationAddress': destinationAddress,
      'sourceLatitude': sourceCoordinates?.latitude,
      'sourceLongitude': sourceCoordinates?.longitude,
      'destinationLatitude': destinationCoordinates?.latitude,
      'destinationLongitude': destinationCoordinates?.longitude,
      'normalLiftSource': normalLiftSource,
      'serviceLiftSource': serviceLiftSource,
      'floorSource': floorSource,
      'normalLiftDestination': normalLiftDestination,
      'serviceLiftDestination': serviceLiftDestination,
      'floorDestination': floorDestination,
    };
  }
}