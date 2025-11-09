import 'dart:convert';

class UserData {
  final String customerName;
  final String email;
  final String pincode;
  final String city;
  final String state;
  final String mobileNo;

  UserData({
    required this.customerName,
    required this.email,
    required this.pincode,
    required this.city,
    required this.state,
    required this.mobileNo,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      customerName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      pincode: json['pincode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'email': email,
      'pincode': pincode,
      'city': city,
      'state': state,
      'mobileNo': mobileNo,
    };
  }
}