import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/PaymentModel.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class PaymentDetailsScreen extends StatefulWidget {
  final int customerId; // Accept customerId
  const PaymentDetailsScreen(
      {super.key, this.customerId = 41}); // Default for now

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  List<PaymentModel> payments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/customer/${widget.customerId}/payments';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            payments = (jsonData['data'] as List)
                .map((data) => PaymentModel.fromJson(data))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load payments';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    if (status?.toLowerCase() == 'success') return Colors.green;
    if (status?.toLowerCase() == 'pending') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Payment Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: darkBlue))
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : payments.isEmpty
                  ? const Center(child: Text("No payments found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final customer = payment.customer;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                    "Customer ID", "${customer?.id ?? 'N/A'}"),
                                _buildDetailRow("Name",
                                    "${customer?.customerName ?? 'N/A'}"),
                                _buildDetailRow(
                                    "Mobile", "${customer?.mobileNo ?? 'N/A'}"),
                                _buildDetailRow(
                                    "E-MAIL", "${customer?.email ?? 'N/A'}"),
                                _buildDetailRow("10% Paid Amount",
                                    "₹${payment.totalAmount ?? '0.00'}"),
                                _buildDetailRow("Payment (Transaction) Id",
                                    "${payment.transactionId ?? 'N/A'}"),
                                _buildDetailRow(
                                    "Time", "${payment.paymentDate ?? 'N/A'}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: darkBlue,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
