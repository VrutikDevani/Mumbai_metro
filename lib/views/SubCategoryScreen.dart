import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_packers_application/lib/constant/app_formatter.dart';

import '../lib/views/map_picker_screen.dart';
import '../models/ServiceEnquiryData.dart';
import 'ServiceSelectionScreen.dart';
import 'ThankYouScreen.dart';
import 'TransportationFormScreen.dart';
import '../lib/views/location_selection_screen.dart';
import '../models/ShiftData.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class SubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int? customerId;
  final String? categoryBannerImg;
  final String? categoryDesc;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.customerId,
    this.categoryBannerImg,
    this.categoryDesc,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class SubCategory {
  final int categoryId;
  final int id;
  final int subCategoryService;
  final String subCategoryName;
  final String categoryName;

  SubCategory({
    required this.categoryId,
    required this.id,
    required this.subCategoryService,
    required this.subCategoryName,
    required this.categoryName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      categoryId: json['category_id'] as int,
      id: json['id'] as int,
      subCategoryService: json['sub_category_service'] as int,
      subCategoryName: json['sub_categoryname'] as String,
      categoryName: json['category_name'] as String,
    );
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<SubCategory> subCategories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    try {
      log('Category name----->>${widget.categoryId}');
      final String apiUrl =
          'https://54kidsstreet.org/api/subCategory/${widget.categoryId}';
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
          final List<dynamic> subCategoryData = jsonData['data'];
          setState(() {
            subCategories = subCategoryData
                .map((data) => SubCategory.fromJson(data))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load subcategories';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load subcategories: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching subcategories: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildSubCategoryButton(SubCategory subCategory) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          onPressed: () {
            if (subCategory.subCategoryService == 1) {
              // Create initial ShiftData for service type 1
              final shiftData = ShiftData(
                serviceId: 0,
                serviceName: subCategory.subCategoryName,
                selectedDate: '',
                selectedTime: '',
                selectedProducts: [],
                customerId: widget.customerId,
                subCategoryId: subCategory.id,
                categoryBannerImg: widget.categoryBannerImg,
                categoryDesc: widget.categoryDesc,
              );

              // Navigate to LocationSelectionScreen first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationSelectionScreen(
                    shiftData: shiftData,
                    navigateToInventory: true,
                  ),
                ),
              );
            } else if (subCategory.subCategoryService == 3) {
              log('In transportation');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransportationFormScreen(
                    subCategoryId: subCategory.id,
                    subCategoryName: subCategory.subCategoryName,
                    customerId: widget.customerId,
                    categoryBannerImg: widget.categoryBannerImg,
                    categoryDesc: widget.categoryDesc,
                  ),
                ),
              );
            } else if (subCategory.subCategoryService == 2) {
              // Call when service with lat and long
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceFormScreenWithCoordinate(
                    subCategoryId: subCategory.id,
                    subCategoryName: subCategory.subCategoryName,
                    customerId: widget.customerId,
                    categoryBannerImg: widget.categoryBannerImg,
                    categoryDesc: widget.categoryDesc,
                  ),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ServiceFormScreen(
              //       subCategoryId: subCategory.id,
              //       subCategoryName: subCategory.subCategoryName,
              //       customerId: widget.customerId,
              //       categoryBannerImg: widget.categoryBannerImg,
              //       categoryDesc: widget.categoryDesc,
              //     ),
              //   ),
              // );
            } else {
              //Call only service
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceFormScreen(
                    subCategoryId: subCategory.id,
                    subCategoryName: subCategory.subCategoryName,
                    customerId: widget.customerId,
                    categoryBannerImg: widget.categoryBannerImg,
                    categoryDesc: widget.categoryDesc,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: mediumBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              subCategory.subCategoryName,
              style: const TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
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
      body: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: darkBlue))
              : errorMessage != null
                  ? Center(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: darkBlue),
                      ),
                    )
                  : subCategories.isEmpty
                      ? const Center(
                          child: Text('No subcategories available',
                              style: TextStyle(color: darkBlue)))
                      : ListView.builder(
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory = subCategories[index];
                            return _buildSubCategoryButton(subCategory);
                          },
                        ),
        ),
      ),
    );
  }
}

class ServiceFormScreenWithCoordinate extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final int? customerId;
  final String? categoryBannerImg;
  final String? categoryDesc;

  const ServiceFormScreenWithCoordinate({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    this.categoryBannerImg,
    this.categoryDesc,
  });

  @override
  State<ServiceFormScreenWithCoordinate> createState() =>
      _ServiceFormScreenWithCoordinateState();
}

class _ServiceFormScreenWithCoordinateState
    extends State<ServiceFormScreenWithCoordinate> {
  final _formKey = GlobalKey<FormState>();
  final _serviceDescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // final _serviceLocationController = TextEditingController();
  final _flatNumberController = TextEditingController();

  final _pickupLocationController = TextEditingController();
  final _destinationLocationController = TextEditingController();

  DateTime? _selectedDate;
  LatLng? _selectedLocation;
  bool _isSubmitting = false;
  // TimeOfDay? _selectedTime;
  String selectedTime = '';
  LatLng? _pickupCoordinates;
  LatLng? _destinationCoordinates;

  String _locationType = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkBlue,
              onPrimary: whiteColor,
              surface: whiteColor,
            ),
            dialogBackgroundColor: whiteColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: darkBlue,
  //             onPrimary: whiteColor,
  //             surface: whiteColor,
  //           ),
  //           dialogBackgroundColor: whiteColor,
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null && picked != _selectedTime) {
  //     setState(() {
  //       _selectedTime = picked;
  //     });
  //   }
  // }

  // Future<void> _pickLocation() async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const MapPickerScreen()),
  //   );
  //
  //   if (result != null && result is Map) {
  //     setState(() {
  //       _serviceLocationController.text =
  //           result['address'] ?? 'Unknown location';
  //       _selectedLocation = result['coordinates'];
  //     });
  //     Fluttertoast.showToast(msg: "Location selected successfully");
  //   } else {
  //     Fluttertoast.showToast(msg: "No location selected");
  //   }
  // }

  Future<void> _pickLocation(String type) async {
    setState(() {
      _locationType = type;
    });

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        if (type == 'pickup') {
          _pickupLocationController.text =
              result['address'] ?? 'Unknown location';
          _pickupCoordinates = result['coordinates'];
        } else {
          _destinationLocationController.text =
              result['address'] ?? 'Unknown location';
          _destinationCoordinates = result['coordinates'];
        }
      });
      Fluttertoast.showToast(
          msg:
              "${type == 'pickup' ? 'Pickup' : 'Destination'} location selected successfully");
    } else {
      Fluttertoast.showToast(msg: "No location selected");
    }
  }

  Future<ServiceEnquiryResponse?> _submitServiceEnquiry() async {
    try {
      const String apiUrl =
          'https://54kidsstreet.org/api/enquiry/storeServiceEnquiry';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['customer_id'] = widget.customerId?.toString() ?? '0';
      request.fields['service_name'] = widget.subCategoryName;
      request.fields['service_description'] = 'NONE';
      request.fields['service_location'] =
          _pickupLocationController.text.trim();
      request.fields['flat_no'] = _flatNumberController.text.trim();
      request.fields['notes'] = _notesController.text.trim();
      request.fields['service_date'] = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      request.fields['pickup_location'] = _pickupLocationController.text.trim();
      request.fields['drop_location'] =
          _destinationLocationController.text.trim();
      if (_pickupCoordinates != null) {
        request.fields['pickup_lat'] = _pickupCoordinates!.latitude.toString();
        request.fields['pickup_lng'] = _pickupCoordinates!.longitude.toString();
      }

      if (_destinationCoordinates != null) {
        request.fields['drop_lat'] =
            _destinationCoordinates!.latitude.toString();
        request.fields['drop_lng'] =
            _destinationCoordinates!.longitude.toString();
      }

      request.fields['shipping_date_time'] =
          _selectedDate != null && selectedTime != ''
              ? '${DateFormat('yyyy-MM-dd').format(
                  DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                  ),
                )} ${AppFormatter.onlyTimeFormatter(selectedTime)}'
              : '';

      request.fields['vehicle_model'] = 'NONE';

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        log('Response---->>${response.body}');
        return ServiceEnquiryResponse.fromJson(jsonData);
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

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        selectedTime != '') {
      setState(() {
        _isSubmitting = true;
      });

      try {
        ServiceEnquiryResponse? response = await _submitServiceEnquiry();

        setState(() {
          _isSubmitting = false;
        });

        if (response != null && response.status) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThankYouScreen(
                serviceResponse: response,
                showAmountScreen: false,
              ),
            ),
          );
        } else {
          if (selectedTime == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a time')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(response?.msg ?? 'Failed to submit service request'),
                backgroundColor: Colors.red,
              ),
            );
          }
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
    } else {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service date')),
        );
      }
    }
  }

  String? _getBannerImageUrl() {
    if (widget.categoryBannerImg != null &&
        widget.categoryBannerImg!.isNotEmpty) {
      debugPrint("_getBannerImageUrl called with: ${widget.categoryBannerImg}");
      return 'https://54kidsstreet.org/admin_assets/category_banner_img/${widget.categoryBannerImg}';
    }
    debugPrint("_getBannerImageUrl: No banner image provided");
    return null;
  }

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM'
  ];

  @override
  void dispose() {
    _serviceDescriptionController.dispose();
    _notesController.dispose();
    // _serviceLocationController.dispose();
    _pickupLocationController.dispose();
    _destinationLocationController.dispose();
    _flatNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasBanner = widget.categoryBannerImg != null &&
        widget.categoryBannerImg!.isNotEmpty;
    bool hasDescription =
        widget.categoryDesc != null && widget.categoryDesc!.isNotEmpty;
    bool showBannerSection = hasBanner || hasDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subCategoryName,
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
      body: Container(
        color: whiteColor,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Service Name',
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.subCategoryName,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (showBannerSection)
                        Container(
                          padding: const EdgeInsets.all(0.0),
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
                                      image: _getBannerImageUrl()!,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint(
                                            "Image loading error: $error");
                                        return Container(
                                          color: lightBlue,
                                          child: const Center(
                                            child: Text(
                                              'Image not available',
                                              style: TextStyle(color: darkBlue),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (hasBanner && hasDescription)
                                const SizedBox(height: 8),
                              if (hasDescription)
                                Text(
                                  widget.categoryDesc!,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // TextFormField(
                      //   controller: _serviceDescriptionController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Service Description',
                      //     labelStyle: const TextStyle(color: darkBlue),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: const BorderSide(color: mediumBlue),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      //   maxLines: 4,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter the service description';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 12),
                        child: const Text(
                          'When to shift',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // Date Field
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  labelStyle: const TextStyle(color: darkBlue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: mediumBlue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select date'
                                      : DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate!),
                                  style: TextStyle(
                                    color: _selectedDate == null
                                        ? Colors.grey
                                        : darkBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Time Field
                          // Expanded(
                          //   child: InkWell(
                          //     onTap: () => _selectTime(context),
                          //     child: InputDecorator(
                          //       decoration: InputDecoration(
                          //         labelText: 'Time',
                          //         labelStyle: const TextStyle(color: darkBlue),
                          //         border: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(10),
                          //         ),
                          //         focusedBorder: OutlineInputBorder(
                          //           borderSide:
                          //               const BorderSide(color: mediumBlue),
                          //           borderRadius: BorderRadius.circular(10),
                          //         ),
                          //       ),
                          //       child: Text(
                          //         _selectedTime == null
                          //             ? 'Select time'
                          //             : _selectedTime!.format(context),
                          //         style: TextStyle(
                          //           color: _selectedTime == null
                          //               ? Colors.grey
                          //               : darkBlue,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Select time',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              value: selectedTime.isEmpty ? null : selectedTime,
                              items: timeSlots.map((String time) {
                                return DropdownMenuItem<String>(
                                  value: time,
                                  child:
                                  Text(time, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedTime = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDate == null || selectedTime == '')
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select date and time',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      // const SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _serviceLocationController,
                      //   readOnly: true,
                      //   decoration: InputDecoration(
                      //     labelText: 'Service Location',
                      //     labelStyle: const TextStyle(color: darkBlue),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: const BorderSide(color: mediumBlue),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     suffixIcon: IconButton(
                      //       icon: const Icon(Icons.location_on,
                      //           color: mediumBlue),
                      //       onPressed: _pickLocation,
                      //     ),
                      //   ),
                      //   onTap: _pickLocation,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please select a service location';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _flatNumberController,
                        decoration: InputDecoration(
                          labelText: widget.subCategoryName.contains('Office')
                              ? 'Office Number'
                              : 'Flat Number',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the flat number';
                          }
                          return null;
                        },
                      ),

                      // InkWell(
                      //   onTap: () => _selectDate(context),
                      //   child: InputDecorator(
                      //     decoration: InputDecoration(
                      //       labelText: 'Service Date',
                      //       labelStyle: const TextStyle(color: darkBlue),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderSide: const BorderSide(color: mediumBlue),
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //     ),
                      //     child: Text(
                      //       _selectedDate == null
                      //           ? 'Select a date'
                      //           : DateFormat('yyyy-MM-dd')
                      //               .format(_selectedDate!),
                      //       style: const TextStyle(color: darkBlue),
                      //     ),
                      //   ),
                      // ),
                      // if (_selectedDate == null)
                      //   const Padding(
                      //     padding: EdgeInsets.only(top: 8.0),
                      //     child: Text(
                      //       'Please select a service date',
                      //       style: TextStyle(color: Colors.red, fontSize: 12),
                      //     ),
                      //   ),
                      // const SizedBox(height: 24),
                      //
                      // // Time Field
                      // Expanded(
                      //   child: InkWell(
                      //     onTap: () => _selectTime(context),
                      //     child: InputDecorator(
                      //       decoration: InputDecoration(
                      //         labelText: 'Time',
                      //         labelStyle: const TextStyle(color: darkBlue),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderSide: const BorderSide(color: mediumBlue),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //       ),
                      //       child: Text(
                      //         _selectedTime == null
                      //             ? 'Select time'
                      //             : _selectedTime!.format(context),
                      //         style: TextStyle(
                      //           color: _selectedTime == null ? Colors.grey : darkBlue,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 16),

                      // Pickup Location
                      TextFormField(
                        controller: _pickupLocationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Pickup Location',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on,
                                color: mediumBlue),
                            onPressed: () => _pickLocation('pickup'),
                          ),
                        ),
                        onTap: () => _pickLocation('pickup'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select pickup location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Destination Location
                      TextFormField(
                        controller: _destinationLocationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Destination Location',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on,
                                color: mediumBlue),
                            onPressed: () => _pickLocation('destination'),
                          ),
                        ),
                        onTap: () => _pickLocation('destination'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select destination location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes/Inventory',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the service description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mediumBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: whiteColor,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceFormScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final int? customerId;
  final String? categoryBannerImg;
  final String? categoryDesc;

  const ServiceFormScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    this.categoryBannerImg,
    this.categoryDesc,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceDescriptionController = TextEditingController();
  final _serviceLocationController = TextEditingController();
  final _flatNumberController = TextEditingController();
  DateTime? _selectedDate;
  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkBlue,
              onPrimary: whiteColor,
              surface: whiteColor,
            ),
            dialogBackgroundColor: whiteColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        _serviceLocationController.text =
            result['address'] ?? 'Unknown location';
        _selectedLocation = result['coordinates'];
      });
      Fluttertoast.showToast(msg: "Location selected successfully");
    } else {
      Fluttertoast.showToast(msg: "No location selected");
    }
  }

  Future<ServiceEnquiryResponse?> _submitServiceEnquiry() async {
    try {
      const String apiUrl =
          'https://54kidsstreet.org/api/enquiry/storeServiceEnquiry';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['customer_id'] = widget.customerId?.toString() ?? '0';
      request.fields['service_name'] = widget.subCategoryName;
      request.fields['service_description'] =
          _serviceDescriptionController.text.isNotEmpty
              ? _serviceDescriptionController.text.trim()
              : 'NONE';
      request.fields['service_location'] =
          _serviceLocationController.text.trim();
      request.fields['flat_no'] = _flatNumberController.text.trim();
      request.fields['service_date'] = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      // if (_selectedLocation != null) {
      //   request.fields['latitude'] = _selectedLocation!.latitude.toString();
      //   request.fields['longitude'] = _selectedLocation!.longitude.toString();
      // }

      //Field which was null

      request.fields['pickup_location'] =
          _serviceLocationController.text.trim();
      request.fields['drop_location'] = 'NONE';

      if (_selectedLocation != null) {
        request.fields['pickup_lat'] = _selectedLocation!.latitude.toString();
        request.fields['pickup_lng'] = _selectedLocation!.longitude.toString();
      }
      request.fields['drop_lat'] = '0';
      request.fields['drop_lng'] = '0';

      request.fields['shipping_date_time'] = '';

      request.fields['vehicle_model'] = 'NONE';

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return ServiceEnquiryResponse.fromJson(jsonData);
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

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        ServiceEnquiryResponse? response = await _submitServiceEnquiry();

        setState(() {
          _isSubmitting = false;
        });

        if (response != null && response.status) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThankYouScreen(
                serviceResponse: response,
                showAmountScreen: false,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response?.msg ?? 'Failed to submit service request'),
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
    } else {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service date')),
        );
      }
    }
  }

  String? _getBannerImageUrl() {
    if (widget.categoryBannerImg != null &&
        widget.categoryBannerImg!.isNotEmpty) {
      debugPrint("_getBannerImageUrl called with: ${widget.categoryBannerImg}");
      return 'https://54kidsstreet.org/admin_assets/category_banner_img/${widget.categoryBannerImg}';
    }
    debugPrint("_getBannerImageUrl: No banner image provided");
    return null;
  }

  @override
  void dispose() {
    _serviceDescriptionController.dispose();
    _serviceLocationController.dispose();
    _flatNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasBanner = widget.categoryBannerImg != null &&
        widget.categoryBannerImg!.isNotEmpty;
    bool hasDescription =
        widget.categoryDesc != null && widget.categoryDesc!.isNotEmpty;
    bool showBannerSection = hasBanner || hasDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subCategoryName,
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
      body: Container(
        color: whiteColor,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Service Name',
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.subCategoryName,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (showBannerSection)
                        Container(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
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
                                      image: _getBannerImageUrl()!,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint(
                                            "Image loading error: $error");
                                        return Container(
                                          color: lightBlue,
                                          child: const Center(
                                            child: Text(
                                              'Image not available',
                                              style: TextStyle(color: darkBlue),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (hasBanner && hasDescription)
                                const SizedBox(height: 8),
                              if (hasDescription)
                                Text(
                                  widget.categoryDesc!,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _flatNumberController,
                        decoration: InputDecoration(
                          labelText: 'Flat Number',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the flat number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serviceLocationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Service Location',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on,
                                color: mediumBlue),
                            onPressed: _pickLocation,
                          ),
                        ),
                        onTap: _pickLocation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a service location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Service Date',
                            labelStyle: const TextStyle(color: darkBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: mediumBlue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Select a date'
                                : DateFormat('dd-MM-yyyy')
                                    .format(_selectedDate!),
                            style: const TextStyle(color: darkBlue),
                          ),
                        ),
                      ),
                      if (_selectedDate == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select a service date',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serviceDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: mediumBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 4,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter the service description';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mediumBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: whiteColor,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
