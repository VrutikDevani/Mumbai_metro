import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_packers_application/views/SubcategorySelectionScreen.dart';
import 'dart:convert';

import '../lib/constant/app_color.dart';
import '../lib/views/location_selection_screen.dart';
import '../models/EnquiryResponse.dart';
import '../models/ShiftData.dart';
import 'EnquiryThankYouScreen.dart';
import 'ProductSelectionScreen.dart';
import '../views/SelectedProduct.dart';
import 'YourFinalScreen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final int? customerId;

  // final String? categoryBannerImg;
  // final String? categoryDesc;
  final ShiftData? shiftData;

  const ServiceSelectionScreen({
    Key? key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    // this.categoryBannerImg,
    // this.categoryDesc,
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

  bool _isSubmitting = false;
  int? _submittedEnquiryId;

  void _updateServiceCount(int serviceId, List<SelectedProduct> products) {
    serviceSelectedProducts[serviceId] = products;
    setState(() {
      serviceProductCounts[serviceId] =
          products.fold(0, (sum, p) => sum + p.count);
    });
  }

  Map<String, String> _formatProductsForAPI(
      {required List<SelectedProduct> selectedItems}) {
    Map<String, String> productsMap = {};

    for (int i = 0; i < selectedItems.length; i++) {
      final product = selectedItems[i];
      productsMap['products_item[$i][product_name]'] = product.productName;
      productsMap['products_item[$i][quantity]'] = product.count.toString();
      productsMap['products_item[$i][product_id]'] =
          product.productId?.toString() ?? '0';
      productsMap['products_item[$i][service_id]'] =
          product.serviceId?.toString() ?? '0';
      productsMap['products_item[$i][product_subcat_id]'] =
          product.productSubCatId?.toString() ?? '0';
    }

    return productsMap;
  }

  String _formatFloorNumber(int floor) {
    if (floor == 0) return "Ground Floor";
    return "$floor";
  }

  void _populateRequestFields(
      http.MultipartRequest request, List<SelectedProduct> selectedItems) {
    request.fields['customer_id'] =
        widget.shiftData?.customerId?.toString() ?? '0';
    request.fields['pickup_location'] = widget.shiftData?.sourceAddress ?? '';
    request.fields['drop_location'] =
        widget.shiftData?.destinationAddress ?? '';
    // request.fields['flat_shop_no'] = '${widget.shiftData?.floorSource}F';
    request.fields['flat_shop_no'] = 'NONE';
    request.fields['shipping_date_time'] =
        '${widget.shiftData?.selectedDate} ${widget.shiftData?.selectedTime}';
    request.fields['floor_number'] =
        /*_formatFloorNumber(widget.shiftData.floorSource);*/
        widget.shiftData!.floorSource.toString();
    request.fields['pickup_services_lift'] =
        /*widget.shiftData.serviceLiftSource ? 'YES' : 'NO'*/
        widget.shiftData!.serviceLiftSource ? '1' : '0';
    request.fields['drop_services_lift'] =
        /*widget.shiftData.serviceLiftDestination ? 'YES' : 'NO'*/
        widget.shiftData!.serviceLiftDestination ? '1' : '0';
    request.fields.addAll(_formatProductsForAPI(selectedItems: selectedItems));
    request.fields['km_distance'] = '0';

    if (widget.shiftData!.sourceCoordinates != null) {
      request.fields['pickup_latitude'] =
          widget.shiftData!.sourceCoordinates!.latitude.toString();
      request.fields['pickup_longitude'] =
          widget.shiftData!.sourceCoordinates!.longitude.toString();
    }

    if (widget.shiftData!.destinationCoordinates != null) {
      request.fields['drop_latitude'] =
          widget.shiftData!.destinationCoordinates!.latitude.toString();
      request.fields['drop_longitude'] =
          widget.shiftData!.destinationCoordinates!.longitude.toString();
    }
    if (widget.shiftData!.floorDestination != null) {
      request.fields['destination_floor_number'] =
          widget.shiftData!.floorDestination.toString();
    }

    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });
  }

  Future<EnquiryResponse?> _submitEnquiry(
      {required List<SelectedProduct> selectedItems}) async {
    try {
      const String apiUrl = 'https://54kidsstreet.org/api/enquiry';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      _populateRequestFields(request, selectedItems);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        debugPrint('Res---->>${response.body}');
        return EnquiryResponse.fromJson(jsonData);
      } else {
        debugPrint('Failed to submit enquiry: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error submitting enquiry: $e');
      return null;
    }
  }

  Future<EnquiryResponse?> _updateEnquiry(
      int enquiryId, List<SelectedProduct> selectedItems) async {
    try {
      final String apiUrl = 'https://54kidsstreet.org/api/enquiry-update';
      debugPrint('Update API URL: $apiUrl');
      debugPrint('Update enquiry ID: $enquiryId');
      // Use POST with _method = PUT for Laravel multipart support
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['_method'] = 'PUT';
      request.fields['id'] = enquiryId.toString();

      if (selectedItems.isNotEmpty && selectedItems.first.serviceId != null) {
        request.fields['service_id'] = selectedItems.first.serviceId.toString();
      } else {
        request.fields['service_id'] = widget.subCategoryId.toString();
      }

      _populateRequestFields(request, selectedItems);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Update Response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        print('Update Res---->>${response.body}');
        return EnquiryResponse.fromJson(jsonData);
      } else {
        print('Failed to update enquiry: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating enquiry: $e');
      return null;
    }
  }

  void _handleSubmit({required List<SelectedProduct> selctedItems}) async {
    if (widget.shiftData?.customerId == null ||
        widget.shiftData!.customerId == 0) {
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
      EnquiryResponse? response;
      debugPrint('Submitted enquiry ID: $_submittedEnquiryId');
      if (_submittedEnquiryId == null) {
        debugPrint('Creating new enquiry');
        // Create new enquiry
        response = await _submitEnquiry(selectedItems: selctedItems);
        if (response != null && response.status && response.data != null) {
          _submittedEnquiryId = response.latestEnquiryId;
        }
        debugPrint('response: ${response}');
        debugPrint('New enquiry created with ID: ${_submittedEnquiryId}');
      } else {
        debugPrint('Updating existing enquiry');
        // Update existing enquiry
        response = await _updateEnquiry(_submittedEnquiryId!, selctedItems);
      }

      setState(() {
        _isSubmitting = false;
      });

      if (response != null && response.status) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EnquiryThankYouScreen(enquiryResponse: response!),
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
    // bool hasBanner = widget.categoryBannerImg != null && widget.categoryBannerImg!.isNotEmpty;
    // bool hasDescription = widget.categoryDesc != null && widget.categoryDesc!.isNotEmpty;
    // bool showBannerSection = hasBanner || hasDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subCategoryName} Inventory',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColor.whiteColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColor.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // if (showBannerSection)
          //   Container(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         if (hasBanner)
          //           Container(
          //             height: 150,
          //             width: double.infinity,
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(8),
          //               color: lightBlue,
          //             ),
          //             child: ClipRRect(
          //               borderRadius: BorderRadius.circular(8),
          //               child: FadeInImage.assetNetwork(
          //                 placeholder: 'assets/parcelwala4.jpg',
          //                 image: 'https://54kidsstreet.org/admin_assets/category_banner_img/${widget.categoryBannerImg}',
          //                 fit: BoxFit.cover,
          //                 imageErrorBuilder: (context, error, stackTrace) {
          //                   return Image.asset(
          //                     'assets/parcelwala4.jpg',
          //                     fit: BoxFit.cover,
          //                   );
          //                 },
          //               ),
          //             ),
          //           ),
          //         if (hasBanner && hasDescription) const SizedBox(height: 8),
          //         if (hasDescription)
          //           Text(
          //             widget.categoryDesc!,
          //             style: const TextStyle(
          //               fontFamily: 'Poppins',
          //               fontSize: 12,
          //               color: Colors.grey,
          //             ),
          //             maxLines: 3,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          // const SizedBox(height: 16),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Select Inventory',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // const SizedBox(height: 16),
          //   ],
          // ),
          // ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColor.darkBlue))
                  : errorMessage != null
                      ? Center(
                          child: Text(errorMessage!,
                              style: const TextStyle(color: AppColor.darkBlue)))
                      : services.isEmpty
                          ? const Center(
                              child: Text('No services available',
                                  style: TextStyle(color: AppColor.darkBlue)))
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
                                                    SubCategorySelectionScreen(
                                                  serviceId: service.id,
                                                  serviceName:
                                                      service.serviceName,
                                                  selectedDate: widget.shiftData
                                                          ?.selectedDate ??
                                                      '',
                                                  selectedTime: widget.shiftData
                                                          ?.selectedTime ??
                                                      '',
                                                  initialSelectedProducts:
                                                      serviceSelectedProducts[
                                                              service.id] ??
                                                          [],
                                                  customerId: widget.customerId,
                                                ),
                                              ),
                                            );
                                            if (result
                                                is List<SelectedProduct>) {
                                              _updateServiceCount(
                                                  service.id, result);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColor.mediumBlue,
                                            minimumSize:
                                                const Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            service.serviceName,
                                            style: TextStyle(
                                              color: AppColor.whiteColor,
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
                  if (_isSubmitting) {
                    return null;
                  } else {
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
                      widget.shiftData!.selectedProducts =
                          serviceSelectedProducts.values
                              .expand((list) => list)
                              .toList();
                      _handleSubmit(
                          selctedItems: widget.shiftData!.selectedProducts);
                      // Navigate directly to confirmation screen (YourFinalScreen)
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         YourFinalScreen(shiftData: widget.shiftData!),
                      //   ),
                      // );
                    } else {
                      // Fallback to old behavior if no shiftData
                      final shiftData = ShiftData(
                        subCategoryDesc:
                            widget.shiftData?.subCategoryDesc ?? '',
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Next',
                        style: TextStyle(
                          color: AppColor.whiteColor,
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
