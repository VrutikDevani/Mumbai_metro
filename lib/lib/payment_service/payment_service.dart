import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../views/HomeServiceView.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() => _instance;

  PaymentService._internal();

  final Razorpay _razorpay = Razorpay();

  bool _initialized = false;

  void _init(BuildContext context, double amount, String orderNumber) {
    if (_initialized) return;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse response) {
      _handlePaymentSuccess(
        context,
        response,
        amount,
        orderNumber,
      );
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
      _handlePaymentError(context, response);
    });
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
        (ExternalWalletResponse response) {
      _handleExternalWallet(context, response);
    });
    _initialized = true;
  }

  void startPayment(
    BuildContext context, {
    required double amount,
    required String name,
    required String orderNumber,
    String description = 'Payment for your order',
    String email = 'test@example.com',
    String contact = '9999999999',
    String apiKey = 'rzp_test_RcOxA7Dz05K2DM',
  }) {
    _init(
      context,
      amount,
      orderNumber,
    );

    var options = {
      'key': apiKey,
      'amount': (amount * 100).toInt(), // Razorpay takes amount in paise
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'currency': 'INR',
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handlePaymentSuccess(
    BuildContext context,
    PaymentSuccessResponse response,
    double amount,
    String orderNumber,
  ) async {
    await callSuccessApi(
      context: context,
      amount: amount,
      orderNumber: orderNumber,
      paymentResponse: response,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful! ID: ${response.paymentId}')),
    );
    debugPrint('Payment Success: ${response.paymentId}');
  }

  void _handlePaymentError(
      BuildContext context, PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
    debugPrint('Payment Failed: ${response.code} | ${response.message}');
  }

  void _handleExternalWallet(
      BuildContext context, ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void clear() {
    _razorpay.clear();
    _initialized = false;
  }

  //call success api

  Future<void> callSuccessApi({
    required BuildContext context,
    required double amount,
    required String orderNumber,
    required PaymentSuccessResponse paymentResponse,
  }) async {
    // Step 1: Call your backend API to initiate payment
    final url = Uri.parse('https://54kidsstreet.org/api/payment/initiate');
    final body = {
      'order_no': orderNumber,
      'amount': amount,
    };

    try {
      debugPrint('📤 Sending payment initiation request to: $url');
      debugPrint('➡️ Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📥 Response Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await callWebhook(context: context, response: paymentResponse);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const HomeServiceView()),
              (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initiation failed.')),
        );
      }
    } catch (e) {
      debugPrint('❌ Payment initiation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating payment: $e')),
      );
    }
  }

  Future<void> callWebhook({
    required BuildContext context,
    required PaymentSuccessResponse response,
  }) async {
    final webhookUrl =
        Uri.parse('https://54kidsstreet.org/api/payment/webhook');
    // Create the payload similar to your backend format
    final webhookBody = {
      "payload": {
        "payment": {
          "entity": {
            "id": response.paymentId ?? '',
            "order_id": response.orderId ?? '',
            "status": "captured",
            "method": "upi"
          }
        }
      }
    };

    try {
      debugPrint('📤 Sending webhook data to: $webhookUrl');
      debugPrint('➡️ Body: ${jsonEncode(webhookBody)}');

      final webhookResponse = await http.post(
        webhookUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(webhookBody),
      );

      debugPrint('📥 Webhook Response Code: ${webhookResponse.statusCode}');
      debugPrint('📥 Webhook Response Body: ${webhookResponse.body}');
    } catch (e) {
      debugPrint('❌ Error sending webhook: $e');
    }
  }
}
