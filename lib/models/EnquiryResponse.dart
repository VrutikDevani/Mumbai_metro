// models/EnquiryResponse.dart
class EnquiryData {
  final String customerId;
  final String pickupLocation;
  final String dropLocation;
  final String flatShopNo;
  final String shippingDateTime;
  final String floorNumber;
  final String destinationFloorNumber;
  final String pickupServicesLift;
  final String dropServicesLift;
  final String productsItem;
  final int orderNo;
   var amount;
   var distance;
  final String updatedAt;
  final String createdAt;
  final int id;

  EnquiryData({
    required this.customerId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.flatShopNo,
    required this.shippingDateTime,
    required this.floorNumber,
    required this.pickupServicesLift,
    required this.dropServicesLift,
    required this.productsItem,
    required this.orderNo,
    required this.distance,
    required this.destinationFloorNumber,
    required this.amount,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory EnquiryData.fromJson(Map<String, dynamic> json) {
    return EnquiryData(
      customerId: json['customer_id']?.toString() ?? '',
      pickupLocation: json['pickup_location'] ?? '',
      dropLocation: json['drop_location'] ?? '',
      flatShopNo: json['flat_shop_no'] ?? '',
      shippingDateTime: json['shipping_date_time'] ?? '',
      floorNumber: json['floor_number'] ?? '',
      destinationFloorNumber: json['destination_floor_number'] ?? '',
      pickupServicesLift: json['pickup_services_lift'] ?? '',
      dropServicesLift: json['drop_services_lift'] ?? '',
      productsItem: json['products_item'] ?? '',
      orderNo: json['order_no'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      amount: json['total_amount']??0,
      distance: json['km_distance']??0,
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}

class EnquiryResponse {
  final bool status;
  final String msg;
  final EnquiryData? data;

  EnquiryResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryResponse(
      status: json['status'] ?? false,
      msg: json['msg'] ?? '',
      data: json['data'] != null
          ? EnquiryData.fromJson(json['data'])
          : null,
    );
  }
}