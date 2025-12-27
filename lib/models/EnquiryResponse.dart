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
      orderNo: int.tryParse(json['order_no']?.toString() ?? '0') ?? 0,
      updatedAt: json['updated_at'] ?? '',
      amount: json['total_amount'] ?? 0,
      distance: json['km_distance'] ?? 0,
      createdAt: json['created_at'] ?? '',
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  String toString() {
    return 'EnquiryData(id: $id, customerId: $customerId, orderNo: $orderNo, amount: $amount)';
  }
}

class EnquiryResponse {
  final bool status;
  final String msg;
  final int totalCft;
  final int latestEnquiryId;
  final EnquiryData? data;

  EnquiryResponse({
    required this.status,
    required this.msg,
    this.data,
    required this.totalCft,
    this.latestEnquiryId = 0,
  });

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryResponse(
      status: json['status'] ?? false,
      msg: json['msg'] ?? '',
      totalCft: json['total_cft'] ?? 0,
      latestEnquiryId: json['latest_enquiry_id'] ?? 0,
      data: json['data'] != null ? EnquiryData.fromJson(json['data']) : null,
    );
  }
}
