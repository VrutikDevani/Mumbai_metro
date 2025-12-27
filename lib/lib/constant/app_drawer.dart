import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:new_packers_application/lib/constant/app_color.dart';
import 'package:new_packers_application/lib/constant/app_strings.dart';
import 'package:new_packers_application/lib/views/MyRequestScreen.dart';
import 'package:new_packers_application/lib/views/payment_details_screen.dart';
import 'package:new_packers_application/views/AppInfoScreen.dart';
import 'package:new_packers_application/views/ContactUsSceern.dart';
import 'package:new_packers_application/views/MyProfileScreen.dart';
import 'package:new_packers_application/views/VendorRegScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/ACServicesScreen.dart' as AppColors;
import '../models/app_policy_model.dart';

class AppDrawer extends StatefulWidget {
  final PolicyModel? privacyModel;
  AppDrawer({super.key, this.privacyModel});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    // fetchPolicy();
    getPolicy();
    super.initState();
  }

  bool isLoading = false;
  PolicyModel? privacyModel;
  getPolicy() {
    privacyModel = widget.privacyModel;
  }
  // fetchPolicy() async {
  //   if (privacyModel == null) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     try {
  //       final String baseUrl = "http://54kidsstreet.org"; // your domain

  //       final response = await http.get(
  //         Uri.parse('$baseUrl/api/policies'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //         },
  //       );

  //       log('➡️ API Response: ${response.body}');
  //       if (response.statusCode == 200) {
  //         final jsonData = jsonDecode(response.body);
  //         // Assuming PolicyModel.fromJson now correctly handles the PolicyData structure
  //         // where contactUs is ContactData and other policies are PolicyItem/AboutUsModel
  //         privacyModel = PolicyModel.fromJson(jsonData);
  //       } else {
  //         log('⚠️ Failed to fetch: ${response.statusCode}');

  //         privacyModel = null;
  //       }
  //     } catch (e) {
  //       log('❌ Error fetching policies: $e');

  //       privacyModel = null;
  //     } finally {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  _buildButton({
    required String name,
    required IconData icon,
    required void Function()? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.mediumBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.whiteColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.whiteColor,
      child: isLoading
          ? Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: AppColor.lightBlue,
                ),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 20,
                ),
                SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10000),
                  child: Image.asset(
                    'assets/applogo.jpeg',
                    height: 120,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "MUMBAI METRO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  "PACKERS AND MOVERS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                _buildButton(
                  icon: Icons.person,
                  name: 'My Profile',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final String? customerId = prefs.getString('customerId');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyProfileScreen(customerId: customerId ?? ''),
                        ));
                  },
                ),
                _buildButton(
                  icon: Icons.calendar_month_outlined,
                  name: 'My Bookings',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final String? customerId = prefs.getString('customerId');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyRequestScreen(
                            customerId: int.parse(customerId ?? ''),
                          ),
                        ));
                  },
                ),
                _buildButton(
                  icon: Icons.calendar_month_outlined,
                  name: 'Payment Details',
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentDetailsScreen(),
                        ));
                  },
                ),
                _buildButton(
                  icon: Icons.business,
                  name: 'Vendor Registration',
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorRegScreen(),
                        ));
                  },
                ),
                _buildButton(
                  icon: Icons.call_to_action_sharp,
                  name: AppStrings.aboutUs,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Note: Assuming AboutUsModel is assignable to PolicyItem for AppInfoScreen
                            builder: (context) => AppInfoScreen(
                              policyItem: privacyModel!.data.aboutUs,
                            ),
                          ));
                    } else {
                      _showSnack(text: 'Something went wrong', isError: true);
                    }
                  },
                ),
                _buildButton(
                  icon: Icons.quick_contacts_dialer_rounded,
                  name: AppStrings.term,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppInfoScreen(
                              policyItem: privacyModel!.data.termsCondition,
                            ),
                          ));
                    } else {
                      _showSnack(text: 'Something went wrong', isError: true);
                    }
                  },
                ),
                _buildButton(
                  icon: Icons.find_in_page,
                  name: AppStrings.refund,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppInfoScreen(
                              policyItem: privacyModel!.data.refundPolicy,
                            ),
                          ));
                    } else {
                      _showSnack(text: 'Something went wrong', isError: true);
                    }
                  },
                ),
                _buildButton(
                  icon: Icons.call,
                  name: AppStrings.contact,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      // *** UPDATED TO USE THE DEDICATED CONTACTUSSCREEN ***
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactUsScreen(
                              contactData: privacyModel!.data.contactUs,
                            ),
                          ));
                    } else {
                      _showSnack(text: 'Something went wrong', isError: true);
                    }
                  },
                ),
                _buildButton(
                  icon: Icons.privacy_tip_outlined,
                  name: AppStrings.privacy,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppInfoScreen(
                              policyItem: privacyModel!.data.privacyPolicy,
                            ),
                          ));
                    } else {
                      _showSnack(text: 'Something went wrong', isError: true);
                    }
                  },
                ),
              ],
            ),
    );
  }
}
