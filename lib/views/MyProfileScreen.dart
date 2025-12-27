import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_packers_application/lib/models/customer_data_model.dart';

import '../lib/constant/app_color.dart';

class MyProfileScreen extends StatefulWidget {
  String customerId;

  MyProfileScreen({super.key, required this.customerId});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  CustomerModel? customerModel;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String baseUrl = "http://54kidsstreet.org";

      final response = await http.get(
        Uri.parse("$baseUrl/api/customer/${widget.customerId}"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      log("➡ API Response: ${response.body}");

      if (response.statusCode == 200) {
        customerModel = CustomerModel.fromJson(jsonDecode(response.body));
      } else {
        log("⚠ Something went wrong");
      }
    } catch (e) {
      log("❌ Error fetching customer: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget detailTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.lightBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColor.darkBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.darkBlue))
          : customerModel == null
              ? const Center(child: Text("No data found"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.darkBlue,
                                  AppColor.mediumBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -50,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColor.lightBlue,
                                child: Text(
                                  customerModel!.data.customerName.isNotEmpty
                                      ? customerModel!.data.customerName[0]
                                          .toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.darkBlue,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      // Existing Info Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              customerModel!.data.customerName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColor.mediumBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Customer ID: ${customerModel!.data.id}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.darkBlue,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Details List
                            detailTile(
                              title: "Email Address",
                              value: customerModel!.data.email,
                              icon: Icons.email_rounded,
                            ),
                            detailTile(
                              title: "Phone Number",
                              value: customerModel!.data.mobileNo,
                              icon: Icons.phone_rounded,
                            ),
                            detailTile(
                              title: "Pincode",
                              value: customerModel!.data.pincode,
                              icon: Icons.push_pin_rounded,
                            ),
                            detailTile(
                              title: "City",
                              value: customerModel!.data.city,
                              icon: Icons.location_city_rounded,
                            ),
                            detailTile(
                              title: "State",
                              value: customerModel!.data.state,
                              icon: Icons.map_rounded,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
