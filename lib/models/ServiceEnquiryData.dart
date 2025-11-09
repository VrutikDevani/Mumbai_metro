// models/ServiceEnquiryResponse.dart
class ServiceEnquiryData {
  final String customerId;
  final int orderNo;
  final String serviceDescription;
  final String flatNo;
  final String serviceLocation;
  final String serviceName;
  final String serviceDate;
  final String updatedAt;
  final String createdAt;
  final int id;
  var amount;
  var distance;

  ServiceEnquiryData({
    required this.customerId,
    required this.orderNo,
    required this.serviceDescription,
    required this.flatNo,
    required this.serviceLocation,
    required this.serviceName,
    required this.serviceDate,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.distance,
    required this.amount,
  });

  factory ServiceEnquiryData.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiryData(
      customerId: json['customer_id']?.toString() ?? '',
      orderNo: json['order_no'] ?? 0,
      serviceDescription: json['service_description'] ?? '',
      flatNo: json['flat_no'] ?? '',
      serviceLocation: json['service_location'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceDate: json['service_date'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
      amount: json['total_amount']??0,
      distance: json['km_distance']??0,
    );
  }
}

class ServiceEnquiryResponse {
  final bool status;
  final String msg;
  final ServiceEnquiryData? data;

  ServiceEnquiryResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  factory ServiceEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiryResponse(
      status: json['status'] ?? false,
      msg: json['msg'] ?? '',
      data: json['data'] != null
          ? ServiceEnquiryData.fromJson(json['data'])
          : null,
    );
  }
}