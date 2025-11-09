import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../lib/views/location_selection_screen.dart';
import '../models/ShiftData.dart';
import 'ProductSelectionScreen.dart';
import '../views/SelectedProduct.dart';
import 'YourFinalScreen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class ServiceSelectionScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final int? customerId;
  final String? categoryBannerImg;
  final String? categoryDesc;
  final ShiftData? shiftData;

  const ServiceSelectionScreen({
    Key? key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    this.categoryBannerImg,
    this.categoryDesc,
    this.shiftData,
  }) : super(key: key);

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class Service {
  final int id;
  final int subCategoryId;
  final String serviceName;

  Service({
    required this.id,
    required this.subCategoryId,
    required this.serviceName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      subCategoryId: json['subCategory_id'] as int,
      serviceName: json['service_name'] as String,
    );
  }
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  List<Service> services = [];
  bool isLoading = true;
  String? errorMessage;
  Map<int, List<SelectedProduct>> serviceSelectedProducts = {};
  Map<int, int> serviceProductCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/Services/${widget.subCategoryId}';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> serviceData = jsonData['data'];
          setState(() {
            services =
                serviceData.map((data) => Service.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load services';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load services: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching services: $e';
        isLoading = false;
      });
    }
  }

  void _updateServiceCount(int serviceId, List<SelectedProduct> products) {
    serviceSelectedProducts[serviceId] = products;
    setState(() {
      serviceProductCounts[serviceId] =
          products.fold(0, (sum, p) => sum + p.count);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasBanner = widget.categoryBannerImg != null && widget.categoryBannerImg!.isNotEmpty;
    bool hasDescription = widget.categoryDesc != null && widget.categoryDesc!.isNotEmpty;
    bool showBannerSection = hasBanner || hasDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subCategoryName} Inventory',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (showBannerSection)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasBanner)
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: lightBlue,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/parcelwala4.jpg',
                          image: 'https://54kidsstreet.org/admin_assets/category_banner_img/${widget.categoryBannerImg}',
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/parcelwala4.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  if (hasBanner && hasDescription) const SizedBox(height: 8),
                  if (hasDescription)
                    Text(
                      widget.categoryDesc!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Services',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: darkBlue))
                  : errorMessage != null
                  ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: darkBlue)))
                  : services.isEmpty
                  ? const Center(
                  child: Text('No services available',
                      style: TextStyle(color: darkBlue)))
                  : ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final count =
                      serviceProductCounts[service.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductSelectionScreen(
                                        serviceId: service.id,
                                        serviceName:
                                        service.serviceName,
                                        selectedDate: widget.shiftData?.selectedDate ?? '',
                                        selectedTime: widget.shiftData?.selectedTime ?? '',
                                        initialSelectedProducts:
                                        serviceSelectedProducts[
                                        service.id] ??
                                            [],
                                        customerId: widget.customerId,
                                      ),
                                ),
                              );
                              if (result is List<SelectedProduct>) {
                                _updateServiceCount(
                                    service.id, result);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mediumBlue,
                              minimumSize:
                              const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              service.serviceName,
                              style: const TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 12,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (serviceProductCounts.values
                      .every((count) => count == 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select products for at least one service'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Update shiftData with selected products
                  if (widget.shiftData != null) {
                    widget.shiftData!.selectedProducts = serviceSelectedProducts.values
                        .expand((list) => list)
                        .toList();

                    // Navigate directly to confirmation screen (YourFinalScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            YourFinalScreen(shiftData: widget.shiftData!),
                      ),
                    );
                  } else {
                    // Fallback to old behavior if no shiftData
                    final shiftData = ShiftData(
                      serviceId: 0,
                      serviceName: 'Multiple Services',
                      selectedDate: '',
                      selectedTime: '',
                      selectedProducts: serviceSelectedProducts.values
                          .expand((list) => list)
                          .toList(),
                      customerId: widget.customerId,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationSelectionScreen(shiftData: shiftData),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}