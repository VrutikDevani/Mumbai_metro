import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_packers_application/lib/constant/app_formatter.dart';
import '../models/ServiceEnquiryData.dart';
import 'ThankYouScreen.dart';
import '../widgets/location_autocomplete_field.dart';
import '../models/search_result.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class TransportationFormScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final int? customerId;
  final String? subCategoryBannerImg;
  final String? subCategoryDesc;

  const TransportationFormScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    this.subCategoryBannerImg,
    this.subCategoryDesc,
  });

  @override
  State<TransportationFormScreen> createState() =>
      _TransportationFormScreenState();
}

class _TransportationFormScreenState extends State<TransportationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupLocationController = TextEditingController();
  final _destinationLocationController = TextEditingController();
  final _pickupHouseNoController = TextEditingController();

  final _flatNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();

  DateTime? _selectedDate;
  // TimeOfDay? _selectedTime;
  LatLng? _pickupCoordinates;
  LatLng? _destinationCoordinates;
  bool _isSubmitting = false;

  String selectedTime = '';

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM'
  ];

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

  Future<ServiceEnquiryResponse?> _submitTransportationEnquiry() async {
    try {
      const String apiUrl =
          'https://54kidsstreet.org/api/enquiry/storeServiceEnquiry';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['customer_id'] = widget.customerId?.toString() ?? '0';
      request.fields['service_name'] = widget.subCategoryName;
      String pickupHouse = _pickupHouseNoController.text.trim();
      String pickupArea = _pickupLocationController.text.trim();
      String fullPickupAddress =
          pickupHouse.isNotEmpty ? "$pickupHouse, $pickupArea" : pickupArea;

      String destArea = _destinationLocationController.text.trim();
      String fullDestAddress = destArea;

      request.fields['service_location'] = fullPickupAddress;
      request.fields['service_description'] = 'NONE';
      request.fields['service_date'] = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';
      request.fields['service_time'] = selectedTime != ''
          ? AppFormatter.onlyTimeFormatter(selectedTime)
          : '';
      request.fields['pickup_location'] = fullPickupAddress;
      request.fields['drop_location'] = fullDestAddress;
      request.fields['flat_no'] = '0';
      request.fields['vehicle_number'] = _vehicleModelController.text.trim();
      // request.fields['notes'] = .text.trim();

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

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        log('Res of transportation----->>${response.body}');
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
        ServiceEnquiryResponse? response = await _submitTransportationEnquiry();

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
              content: Text(
                  response?.msg ?? 'Failed to submit transportation request'),
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
          const SnackBar(content: Text('Please select a date')),
        );
      } else if (selectedTime == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _destinationLocationController.dispose();
    _flatNumberController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if banner and description exist
    bool hasBanner = widget.subCategoryBannerImg != null &&
        widget.subCategoryBannerImg!.isNotEmpty;
    bool hasDescription =
        widget.subCategoryDesc != null && widget.subCategoryDesc!.isNotEmpty;
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
                      // Conditional Banner and Description Section
                      if (showBannerSection)
                        Container(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Banner Image - Only if exists
                              if (hasBanner)
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: lightBlue,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/parcelwala4.jpg',
                                      image:
                                          'https://54kidsstreet.org/admin_assets/category_banner_img/${widget.subCategoryBannerImg}',
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/parcelwala4.jpg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (hasBanner && hasDescription)
                                const SizedBox(height: 8),
                              // Description - Only if exists
                              if (hasDescription)
                                Text(
                                  widget.subCategoryDesc!,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: mediumBlue.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkBlue.withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.subCategoryName,
                                        style: const TextStyle(
                                          color: darkBlue,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Service Name Display
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const Text(
                      //       'Service',
                      //       style: TextStyle(
                      //         color: darkBlue,
                      //         fontSize: 16,
                      //         fontFamily: 'Poppins',
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Container(
                      //       width: double.infinity,
                      //       padding: const EdgeInsets.symmetric(
                      //           vertical: 12, horizontal: 16),
                      //       decoration: BoxDecoration(
                      //         border: Border.all(color: Colors.grey[400]!),
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       child: Text(
                      //         widget.subCategoryName,
                      //         style: const TextStyle(
                      //           color: darkBlue,
                      //           fontSize: 16,
                      //           fontFamily: 'Poppins',
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                      const SizedBox(height: 20),
                      // Date and Time Row
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
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              value: selectedTime.isEmpty ? null : selectedTime,
                              items: timeSlots.map((String time) {
                                return DropdownMenuItem<String>(
                                  value: time,
                                  child: Text(time,
                                      overflow: TextOverflow.ellipsis),
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

                      const SizedBox(height: 16),
                      // Flat Number
                      // TextFormField(
                      //   controller: _flatNumberController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Flat No.',
                      //     labelStyle: const TextStyle(color: darkBlue),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: const BorderSide(color: mediumBlue),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter flat number';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 16),

                      // Pickup Location
                      // Pickup Location
                      const Text('Pickup Location',
                          style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pickupHouseNoController,
                        decoration: InputDecoration(
                          labelText: 'House / Flat No',
                          labelStyle: const TextStyle(color: darkBlue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: mediumBlue),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LocationAutocompleteField(
                        controller: _pickupLocationController,
                        hintText: 'Search Pickup Society / Area',
                        onLocationSelected: (result) {
                          setState(() {
                            _pickupCoordinates = result.location;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Destination Location
                      const Text('Destination Location',
                          style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      LocationAutocompleteField(
                        controller: _destinationLocationController,
                        hintText: 'Search Destination Society / Area',
                        onLocationSelected: (result) {
                          setState(() {
                            _destinationCoordinates = result.location;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Model
                      TextFormField(
                        controller: _vehicleModelController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Model',
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
                            return 'Please enter vehicle model';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Submit Button - Fixed at bottom
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
