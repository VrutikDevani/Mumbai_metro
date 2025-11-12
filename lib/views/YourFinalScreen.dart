import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ShiftData.dart';
import '../models/EnquiryResponse.dart';
import 'EnquiryThankYouScreen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class YourFinalScreen extends StatefulWidget {
  final ShiftData shiftData;

  const YourFinalScreen({super.key, required this.shiftData});

  @override
  State<YourFinalScreen> createState() => _YourFinalScreenState();
}

class _YourFinalScreenState extends State<YourFinalScreen> {
  bool _isSubmitting = false;

  // String _formatProductsForAPI() {
  //   List<Map<String, String>> productsList = widget.shiftData.selectedProducts
  //       .map((product) => {
  //     "product_name": product.productName,
  //     "quantity": product.count.toString()
  //   })
  //       .toList();
  //
  //   print('Data---->>${jsonEncode(productsList)}');
  //   return jsonEncode(productsList);
  // }

  Map<String, String> _formatProductsForAPI() {
    Map<String, String> productsMap = {};

    for (int i = 0; i < widget.shiftData.selectedProducts.length; i++) {
      final product = widget.shiftData.selectedProducts[i];
      productsMap['products_item[$i][product_name]'] = product.productName;
      productsMap['products_item[$i][quantity]'] = product.count.toString();
    }

    return productsMap;
  }

  String _formatFloorNumber(int floor) {
    if (floor == 0) return "Ground Floor";
    return "$floor";
  }

  Future<EnquiryResponse?> _submitEnquiry() async {
    try {
      const String apiUrl = 'https://54kidsstreet.org/api/enquiry';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['customer_id'] = widget.shiftData.customerId?.toString() ?? '0';
      request.fields['pickup_location'] = widget.shiftData.sourceAddress ?? '';
      request.fields['drop_location'] = widget.shiftData.destinationAddress ?? '';
      request.fields['flat_shop_no'] = '${widget.shiftData.floorSource}F';
      request.fields['shipping_date_time'] = '${widget.shiftData.selectedDate} ${widget.shiftData.selectedTime}';
      request.fields['floor_number'] = /*_formatFloorNumber(widget.shiftData.floorSource);*/ widget.shiftData.floorSource.toString();
      request.fields['destination_floor_number'] = /*_formatFloorNumber(widget.shiftData.floorSource);*/ widget.shiftData.floorSource.toString();
      request.fields['pickup_services_lift'] = /*widget.shiftData.serviceLiftSource ? 'YES' : 'NO'*/ widget.shiftData.floorDestination.toString();
      request.fields['drop_services_lift'] = /*widget.shiftData.serviceLiftDestination ? 'YES' : 'NO'*/ widget.shiftData.serviceLiftSource ? '0' : '1';
      request.fields.addAll(_formatProductsForAPI());
      request.fields['km_distance'] = '0';

      if (widget.shiftData.sourceCoordinates != null) {
        request.fields['pickup_latitude'] = widget.shiftData.sourceCoordinates!.latitude.toString();
        request.fields['pickup_longitude'] = widget.shiftData.sourceCoordinates!.longitude.toString();
      }

      if (widget.shiftData.destinationCoordinates != null) {
        request.fields['drop_latitude'] = widget.shiftData.destinationCoordinates!.latitude.toString();
        request.fields['drop_longitude'] = widget.shiftData.destinationCoordinates!.longitude.toString();
      }

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        print('Res---->>${response.body}');
        return EnquiryResponse.fromJson(jsonData);
      } else {
        print('Failed to submit enquiry: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error submitting enquiry: $e');
      return null;
    }
  }

  void _handleSubmit() async {
    if (widget.shiftData.customerId == null || widget.shiftData.customerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid customer ID. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      EnquiryResponse? response = await _submitEnquiry();

      setState(() {
        _isSubmitting = false;
      });

      if (response != null && response.status) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EnquiryThankYouScreen(enquiryResponse: response),
          ),
          // MaterialPageRoute(
          //   builder: (context) => EnquiryBookingConfirmationWithAmount(enquiryResponse: response),
          // ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.msg ?? 'Failed to submit enquiry'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Confirmation',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildInfoCard("Service", widget.shiftData.serviceName),
                    _buildInfoCard("Date", widget.shiftData.selectedDate),
                    _buildInfoCard("Time", widget.shiftData.selectedTime),
                    _buildInfoCard("Total Products",
                        widget.shiftData.getTotalProductCount().toString()),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected Products:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...widget.shiftData.selectedProducts.map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "• ${p.productName}: ${p.count}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: darkBlue,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard("Source Location",
                        widget.shiftData.sourceAddress ?? "Location not selected"),
                    _buildInfoCard("Destination Location",
                        widget.shiftData.destinationAddress ?? "Location not selected"),
                    _buildInfoCard("Source Floor",
                        _formatFloorNumber(widget.shiftData.floorSource)),
                    _buildInfoCard("Destination Floor",
                        _formatFloorNumber(widget.shiftData.floorDestination)),
                    _buildInfoCard("Normal Lift Source",
                        widget.shiftData.normalLiftSource ? "Available" : "Not Available"),
                    _buildInfoCard("Service Lift Source",
                        widget.shiftData.serviceLiftSource ? "Available" : "Not Available"),
                    _buildInfoCard("Normal Lift Destination",
                        widget.shiftData.normalLiftDestination ? "Available" : "Not Available"),
                    _buildInfoCard("Service Lift Destination",
                        widget.shiftData.serviceLiftDestination ? "Available" : "Not Available"),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mediumBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : const Text(
                    "Submit Enquiry",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkBlue,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: darkBlue,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}