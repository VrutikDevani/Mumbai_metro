import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_packers_application/lib/constant/app_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/PendingScreen.dart';
import '../payment_service/payment_service.dart';

class MyRequestScreen extends StatefulWidget {
  final int customerId;

  const MyRequestScreen({super.key, required this.customerId});

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen> {
  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color whiteColor = Color(0xFFf7f7f7);

  List<dynamic> enquiries = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
  }

  Future<void> _fetchEnquiries() async {
    final prefs = await SharedPreferences.getInstance();
    String? customerId = await prefs.getString('customerId');
    final url =
        "https://54kidsstreet.org/api/enquiry/customer-list?customer_id=${customerId ?? ''}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true) {
          setState(() {
            enquiries = jsonData["data"];
            log('Data req len---->>${enquiries.length}');
            log('Data req len---->>${response.body}');
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData["msg"] ?? "No data found";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  int calculatePercentage(double amount) {
    return (amount * (10 / 100)).toInt();
  }

  int calculateTotalAmount(double amount, int addingAmount) {
    return (amount + addingAmount).toInt();
  }

  bool isPaymentLoading = false;

  _payButtonSubmit({
    required int amount,
    required String orderNumber,
  }) {
    if (amount != 0 && orderNumber != '') {
      try {
        setState(() {
          isPaymentLoading = true;
        });
        PaymentService().startPayment(
          context,
          amount: amount,
          name: 'User',
          orderNumber: orderNumber,
        );
      } catch (e) {
        setState(() {
          isPaymentLoading = false;
        });
        debugPrint('Error--->>${e.toString()}');
      } finally {
        setState(() {
          isPaymentLoading = false;
        });
      }
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('QR screen',style: TextStyle(fontFamily: 'Poppins',color: Colors.white),),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      // Navigator.pushReplacement(
      //   context,
      // MaterialPageRoute(
      //   builder: (context) => EnquiryThankYouScreen(enquiryResponse: response),
      // ),
      // MaterialPageRoute(
      //   builder: (context) => EnquiryThankYouScreen(
      //       enquiryResponse: widget.enquiryResponse),
      // ),
      // );
    } else {
      debugPrint('Both are blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Booking',
          style: TextStyle(
              color: darkBlue, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: darkBlue))
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: darkBlue),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: enquiries.length,
                  itemBuilder: (context, index) {
                    final enquiry = enquiries[index];
                    final productsItem = enquiry["products_item"];

                    List<dynamic> products = [];
                    try {
                      if (productsItem is String) {
                        products = json.decode(productsItem);
                      } else if (productsItem is List) {
                        products = productsItem;
                      }
                    } catch (e) {
                      products = [];
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Request #${enquiry["order_no"]}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PendingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: mediumBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Pending",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "From: ${enquiry["pickup_location"] ?? ""}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Pickup Floor: ${enquiry["floor_number"] ?? "-"}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Lift (Pickup): ${enquiry["pickup_services_lift"] ?? "-"}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "To: ${enquiry["drop_location"] ?? ""}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Destination Floor: ${enquiry["destination_floor_number"] ?? "N/A"}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Lift (Drop): ${enquiry["drop_services_lift"] ?? "-"}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Shifting Date: ${AppFormatter.dateFormater(date: enquiry["shipping_date_time"] ?? "N/A")}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Shifting Time: ${AppFormatter.timeFormater(date: enquiry["shipping_date_time"] ?? "N/A")}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Created Date: ${AppFormatter.dateFormater(date: enquiry["created_at"] ?? "N/A")}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Total Distance: ${enquiry["km_distance"]} KM",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Total Amount: \u20B9${enquiry["total_amount"]}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            "Estimate Amount: \u20B9${calculatePercentage(double.parse((enquiry["total_amount"] ?? 0).toString()))}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 12),

                          // Products
                          if (products.isNotEmpty) ...[
                            const Text(
                              "Inventory:",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: products.map((p) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p["product_name"] ?? "",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      "Qty: ${p["quantity"]}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => isPaymentLoading
                                    ? null
                                    : _payButtonSubmit(
                                        orderNumber: (enquiry["order_no"] ?? '')
                                            .toString(),
                                        amount: calculatePercentage(
                                            double.parse(
                                                (enquiry["total_amount"] ?? 0)
                                                    .toString()))),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mediumBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
