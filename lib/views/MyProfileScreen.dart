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

  Widget detailTile(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Expanded(
            flex: 2,
            child: Text(
              '${title} :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.lightBlue,
                fontFamily: 'Poppins',
              ),
            )),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColor.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customerModel == null
              ? const Center(child: Text("No data found"))
              : ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    detailTile(
                        "Customer ID", customerModel!.data.id.toString()),
                    detailTile("Name", customerModel!.data.customerName),
                    detailTile("Email", customerModel!.data.email),
                    detailTile("Mobile", customerModel!.data.mobileNo),
                    detailTile("Pincode", customerModel!.data.pincode),
                    detailTile("City", customerModel!.data.city),
                    detailTile("State", customerModel!.data.state),
                  ],
                ),
    );
  }
}
