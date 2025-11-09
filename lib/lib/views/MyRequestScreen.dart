import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../views/PendingScreen.dart';

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
    final url =
        "https://54kidsstreet.org/api/enquiry/customer-list?customer_id=${widget.customerId}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == true) {
          setState(() {
            enquiries = jsonData["data"];
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
          'My Requests',
          style: TextStyle(color: darkBlue, fontSize: 18, fontWeight: FontWeight.w500),
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
                            builder: (context) =>
                                PendingScreen(),
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
                  "To: ${enquiry["drop_location"] ?? ""}",
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54),
                ),
                Text(
                  "Floor: ${enquiry["floor_number"] ?? "-"}",
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54),
                ),
                Text(
                  "Lift (Pickup): ${enquiry["pickup_services_lift"] ?? "-"}",
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54),
                ),
                Text(
                  "Lift (Drop): ${enquiry["drop_services_lift"] ?? "-"}",
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // Products
                if (products.isNotEmpty) ...[
                  const Text(
                    "Products:",
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
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
