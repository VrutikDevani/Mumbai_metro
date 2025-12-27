import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/location_autocomplete_field.dart';
import 'package:new_packers_application/lib/constant/app_formatter.dart';
import 'package:new_packers_application/lib/constant/app_strings.dart';

import '../models/ServiceEnquiryData.dart';
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
  final String bannerImage;
  final String subCateIconImage;
  final String subCateDescription;

  SubCategory({
    required this.categoryId,
    required this.id,
    required this.subCategoryService,
    required this.subCategoryName,
    required this.categoryName,
    required this.bannerImage,
    required this.subCateIconImage,
    required this.subCateDescription,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      categoryId: json['category_id'] as int,
      id: json['id'] as int,
      subCategoryService: json['sub_category_service'] as int,
      subCategoryName: json['sub_categoryname'] as String,
      categoryName: json['category_name'] as String,
      bannerImage: json['sub_banner_image'] ?? '',
      subCateIconImage: json['sub_icon_image'] ?? '',
      subCateDescription: json['sub_category_desc'] ?? '',
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
    String? imageUrl = subCategory.subCateIconImage != '' &&
            subCategory.subCateIconImage.isNotEmpty
        ? AppStrings.subcategoryIconImage(
            iconImage: subCategory.subCateIconImage)
        : null;
    IconData defaultIcon = Icons.category;

    log('Image URL---->>${imageUrl}');
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
                subCategoryDesc: subCategory.subCateDescription,
                serviceId: 0,
                serviceName: subCategory.subCategoryName,
                selectedDate: '',
                selectedTime: '',
                selectedProducts: [],
                customerId: widget.customerId,
                subCategoryId: subCategory.id,
                subCategoryBannerImg: subCategory.bannerImage,
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
                    subCategoryBannerImg: subCategory.bannerImage,
                    subCategoryDesc: subCategory.subCateDescription,
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
                    subCategoryBanner: subCategory.bannerImage,
                    subCategoryDesc: subCategory.subCateDescription,
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
                    subCategoryBannerImg: subCategory.bannerImage,
                    subCategoryDesc: subCategory.subCateDescription,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              spacing: 20,
              children: [
                Center(
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? SizedBox(
                            height: 40,
                            width: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/parcelwala4.jpg',
                                image: imageUrl,
                                fit: BoxFit.fill,
                                alignment: Alignment.center,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Icon(defaultIcon,
                                      color: mediumBlue, size: 28);
                                },
                              ),
                            ),
                          )
                        // : Icon(defaultIcon, color: AppColor.whiteColor, size: 28),
                        : SizedBox(
                            height: 40,
                            width: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/parcelwala4.jpg',
                                fit: BoxFit.fill,
                                alignment: Alignment.center,
                              ),
                            ),
                          )),
                Expanded(
                  child: Text(
                    subCategory.subCategoryName,
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
  final String? subCategoryBanner;
  final String? subCategoryDesc;

  const ServiceFormScreenWithCoordinate({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    this.subCategoryBanner,
    this.subCategoryDesc,
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
  final _pickupHouseNoController = TextEditingController();

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

  Future<ServiceEnquiryResponse?> _submitServiceEnquiry() async {
    try {
      const String apiUrl =
          'https://54kidsstreet.org/api/enquiry/storeServiceEnquiry';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['customer_id'] = widget.customerId?.toString() ?? '0';
      request.fields['service_name'] = widget.subCategoryName;
      request.fields['service_description'] = 'NONE';
      String pickupHouse = _pickupHouseNoController.text.trim();
      String pickupArea = _pickupLocationController.text.trim();
      String fullPickupAddress =
          pickupHouse.isNotEmpty ? "$pickupHouse, $pickupArea" : pickupArea;

      String destArea = _destinationLocationController.text.trim();
      String fullDestAddress = destArea;

      request.fields['service_location'] = fullPickupAddress;
      request.fields['flat_no'] = _flatNumberController.text.trim();
      request.fields['notes'] = _notesController.text.trim();
      request.fields['service_date'] = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      request.fields['pickup_location'] = fullPickupAddress;
      request.fields['drop_location'] = fullDestAddress;
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
    bool hasBanner = widget.subCategoryBanner != null &&
        widget.subCategoryBanner!.isNotEmpty;
    bool hasDescription =
        widget.subCategoryDesc != '' && widget.subCategoryDesc!.isNotEmpty;
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
                      const SizedBox(height: 10),
                      if (showBannerSection)
                        Container(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      image: AppStrings.subcategoryBannerImage(
                                        bannerImage:
                                            widget.subCategoryBanner ?? '',
                                      ),
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
                                  widget.subCategoryDesc ?? "",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.black,
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
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes/Special Instructions',
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
  final String? subCategoryBannerImg;
  final String? subCategoryDesc;

  const ServiceFormScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    this.customerId,
    this.subCategoryBannerImg,
    this.subCategoryDesc,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceDescriptionController = TextEditingController();
  final _serviceLocationController = TextEditingController();
  final _serviceHouseNoController = TextEditingController();
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
      String houseNo = _flatNumberController.text.trim();
      String area = _serviceLocationController.text.trim();
      String fullAddress = houseNo.isNotEmpty ? "$houseNo, $area" : area;

      request.fields['service_location'] = fullAddress;
      request.fields['flat_no'] = _flatNumberController.text.trim();
      request.fields['service_date'] = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      // if (_selectedLocation != null) {
      //   request.fields['latitude'] = _selectedLocation!.latitude.toString();
      //   request.fields['longitude'] = _selectedLocation!.longitude.toString();
      // }

      //Field which was null

      request.fields['pickup_location'] = fullAddress;
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

  @override
  void dispose() {
    _serviceDescriptionController.dispose();
    _serviceLocationController.dispose();
    _flatNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const SizedBox(height: 16),
                      //     const Text(
                      //       'Service Name',
                      //       style: TextStyle(
                      //         color: darkBlue,
                      //         fontSize: 16,
                      //         fontFamily: 'Poppins',
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

                      if (showBannerSection)
                        Container(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
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
                                      image: AppStrings.subcategoryBannerImage(
                                          bannerImage:
                                              widget.subCategoryBannerImg ??
                                                  ''),
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint(
                                            "Image loading error: $error");
                                        return Container(
                                          height: 150,
                                          color: whiteColor,
                                          child: Center(
                                            child: Image.asset(
                                              'assets/applogo.jpeg',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (hasBanner && hasDescription) ...[
                                const SizedBox(height: 16),
                              ],
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
                      // Service Location
                      const Text('Service Location',
                          style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const SizedBox(height: 10),
                      LocationAutocompleteField(
                        controller: _serviceLocationController,
                        hintText: 'Search Service Society / Area',
                        onLocationSelected: (result) {
                          setState(() {
                            _selectedLocation = result.location;
                            _serviceLocationController.text = result.title;
                          });
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
                          labelText: 'Notes/Special Instructions',
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
