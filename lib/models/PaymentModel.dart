class PaymentModel {
  final int? id;
  final String? transactionId;
  final String? orderNo;
  final String? totalAmount;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentDate;
  final String? currency;

  final Customer? customer;

  PaymentModel({
    this.id,
    this.transactionId,
    this.orderNo,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentDate,
    this.currency,
    this.customer,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      orderNo: json['order_no'],
      totalAmount: json['total_amount'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'],
      currency: json['currency'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }
}

class Customer {
  final int? id;
  final String? customerName;
  final String? mobileNo;
  final String? email;

  Customer({
    this.id,
    this.customerName,
    this.mobileNo,
    this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerName: json['customer_name'],
      mobileNo: json['mobile_no'],
      email: json['email'],
    );
  }
}
