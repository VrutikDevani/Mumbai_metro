import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_packers_application/lib/constant/app_strings.dart';

import '../lib/constant/app_color.dart';
import '../lib/views/OTPSuccessView.dart' as AppColors;

class VendorRegScreen extends StatefulWidget {
  const VendorRegScreen({super.key});

  @override
  State<VendorRegScreen> createState() => _VendorRegScreenState();
}

class _VendorRegScreenState extends State<VendorRegScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController businessName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController businessDes = TextEditingController();
  TextEditingController businessExp = TextEditingController();
  TextEditingController serviceArea = TextEditingController();
  List<String> businessType = [];

  bool _isSubmitting = false;

  _changeCheckBox({required String service}) {
    setState(() {
      if (businessType.contains(service)) {
        businessType.remove(service);
      } else {
        businessType.add(service);
      }

      log('Type list--->>${businessType}');
    });
  }

  _showSnack({required String text, required bool isError}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal,
            color: AppColors.whiteColor,
            backgroundColor: isError ? Colors.red : Colors.green,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  _submitButton() async {
    if (_formKey.currentState!.validate() && businessType.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      final url = Uri.parse('https://54kidsstreet.org/api/vendors/register');

      final Map<String, dynamic> body = {
        "full_name": fullName.text,
        "business_name": businessName.text,
        "address": address.text,
        "mobile_no": mobileNumber.text,
        "email": email.text,
        "business_type": businessType.toList(),
        "business_description": businessDes.text,
        "experience_years": businessExp.text,
        "service_areas": serviceArea.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );

        log('Res--->>${response.body}');
        if (response.statusCode == 201) {
          final jsonResponse = jsonDecode(response.body);

          if (jsonResponse['status'] == true) {
            log('✅ Success: ${jsonResponse['message']}');
            _showSnack(
                text: 'Your details has been successfully submitted',
                isError: false);
            Navigator.pop(context);
          } else {
            log('⚠️ Failed: ${jsonResponse['message']}');
            _showSnack(text: jsonResponse['message'], isError: true);
          }
        } else {
          log('❌ Server Error: ${response.statusCode}');
          _showSnack(
              text: 'Server Error: ${response.statusCode},${response.body}',
              isError: true);
        }
      } catch (e) {
        log('🚨 Exception: $e');
        _showSnack(text: 'Exception: $e', isError: true);
      }

      setState(() {
        _isSubmitting = false;
      });
    } else {
      if (businessType.isEmpty) {
        _showSnack(text: 'Please select business type', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendor Registration',
          style: const TextStyle(
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
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Fill in the below details, vendor registration (partners)",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkBlue,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: fullName,
                  decoration: InputDecoration(
                    labelText: 'Vendor Full Name',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vendor full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: businessName,
                  decoration: InputDecoration(
                    labelText: 'Business Name',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: 'Business Address',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mobileNumber,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Business Type',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                    fontSize: 17,
                  ),
                ),
                _buildCheckBoxText(
                  name: AppStrings.packers,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.packers),
                  value: businessType.contains(AppStrings.packers),
                ),
                _buildCheckBoxText(
                  name: AppStrings.acService,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.acService),
                  value: businessType.contains(AppStrings.acService),
                ),
                _buildCheckBoxText(
                  name: AppStrings.cleaningService,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.cleaningService),
                  value: businessType.contains(AppStrings.cleaningService),
                ),
                _buildCheckBoxText(
                  name: AppStrings.carpentryService,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.carpentryService),
                  value: businessType.contains(AppStrings.carpentryService),
                ),
                _buildCheckBoxText(
                  name: AppStrings.plumberService,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.plumberService),
                  value: businessType.contains(AppStrings.plumberService),
                ),
                _buildCheckBoxText(
                  name: AppStrings.electricianService,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.electricianService),
                  value: businessType.contains(AppStrings.electricianService),
                ),
                _buildCheckBoxText(
                  name: AppStrings.interiorDesign,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.interiorDesign),
                  value: businessType.contains(AppStrings.interiorDesign),
                ),
                _buildCheckBoxText(
                  name: AppStrings.pestControl,
                  onChanged: (p0) =>
                      _changeCheckBox(service: AppStrings.pestControl),
                  value: businessType.contains(
                    AppStrings.pestControl,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: businessDes,
                  decoration: InputDecoration(
                    labelText: 'Business Description',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: businessExp,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Business Experience (In Year)',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business experience';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: serviceArea,
                  decoration: InputDecoration(
                    labelText: 'Business Areas',
                    labelStyle: const TextStyle(color: AppColor.darkBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.mediumBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business area';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.mediumBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              color: AppColor.whiteColor,
                              strokeWidth: 2,
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                color: AppColor.whiteColor,
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
        ),
      ),
    );
  }

  Widget _buildCheckBoxText({
    required String name,
    required void Function(bool?)? onChanged,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Checkbox(
            activeColor: AppColor.darkBlue,
            value: value,
            onChanged: onChanged,
          ),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              color: AppColor.darkBlue,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }
}
