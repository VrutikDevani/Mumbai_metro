import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:new_packers_application/lib/constant/app_color.dart';
import 'package:new_packers_application/lib/constant/app_strings.dart';
import 'package:new_packers_application/views/AppInfoScreen.dart';
import 'package:new_packers_application/views/MyProfileScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/ACServicesScreen.dart' as AppColors;
import '../models/app_policy_model.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    fetchPolicy();
    super.initState();
  }

  bool isLoading = false;

  PolicyModel? privacyModel;

  fetchPolicy() async {
    if (privacyModel == null) {
      setState(() {
        isLoading = true;
      });
      try {
        final String baseUrl = "http://54kidsstreet.org"; // your domain

        final response = await http.get(
          Uri.parse('$baseUrl/api/policies'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        log('➡️ API Response: ${response.body}');
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          privacyModel = PolicyModel.fromJson(jsonData);
        } else {
          log('⚠️ Failed to fetch: ${response.statusCode}');

          privacyModel = null;
        }
      } catch (e) {
        log('❌ Error fetching policies: $e');

        privacyModel = null;
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  _buildButton({
    required String name,
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 40,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final String? customerId =
                              prefs.getString('customerId');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyProfileScreen(
                                    customerId: customerId ?? ''),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.mediumBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.whiteColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                  height: 30,
                ),
                _buildButton(
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
                _buildButton(
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
                  name: AppStrings.contact,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppInfoScreen(
                              policyItem: privacyModel!.data.contactUs,
                            ),
                          ));
                    } else {
                      _showSnack(text: 'Something went wrong', isError: true);
                    }
                  },
                ),
                _buildButton(
                  name: AppStrings.aboutUs,
                  onTap: () {
                    if (privacyModel?.data != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppInfoScreen(
                              policyItem: privacyModel!.data.aboutUs,
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
