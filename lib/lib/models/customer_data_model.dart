


class CustomerModel {
  final bool status;
  final CustomerData data;

  CustomerModel({
    required this.status,
    required this.data,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      status: json['status'] ?? false,
      data: CustomerData.fromJson(json['data'] ?? {}),
    );
  }
}

class CustomerData {
  final int id;
  final String customerName;
  final String email;
  final String pincode;
  final String city;
  final String state;
  final String mobileNo;

  CustomerData({
    required this.id,
    required this.customerName,
    required this.email,
    required this.pincode,
    required this.city,
    required this.state,
    required this.mobileNo,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      email: json['email'] ?? '',
      pincode: json['pincode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
    );
  }
}
