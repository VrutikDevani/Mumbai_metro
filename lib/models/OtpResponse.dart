// models/OtpResponse.dart
class OtpResponse {
  final bool status;
  final String msg;
  final int customerId;

  OtpResponse({
    required this.status,
    required this.msg,
    required this.customerId,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'] ?? false,
      msg: json['msg'] ?? '',
      customerId: json['customer_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
      'customer_id': customerId,
    };
  }
}