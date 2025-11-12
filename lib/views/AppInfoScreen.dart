import 'package:flutter/material.dart';
import 'package:new_packers_application/lib/constant/app_color.dart';
import 'package:new_packers_application/lib/models/app_policy_model.dart';

class AppInfoScreen extends StatelessWidget {
  PolicyItem policyItem;

  AppInfoScreen({super.key, required this.policyItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  Text(
            policyItem.title,
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          policyItem.content,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal,
            color: AppColor.darkBlue,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
