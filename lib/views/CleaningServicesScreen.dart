import 'package:flutter/material.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class CleaningServicesScreen extends StatelessWidget {
  const CleaningServicesScreen({super.key});

  final List<Map<String, dynamic>> buttons = const [
    {'title': 'Apartment / Bungalow', 'startColor': darkBlue, 'endColor': lightBlue},
    {'title': 'Bathroom Cleaning', 'startColor': mediumBlue, 'endColor': darkBlue},
    {'title': 'Carpet Cleaning', 'startColor': lightBlue, 'endColor': mediumBlue},
    {'title': 'Full House Cleaning', 'startColor': darkBlue, 'endColor': mediumBlue},
    {'title': 'Kitchen Cleaning', 'startColor': mediumBlue, 'endColor': lightBlue},
    {'title': 'Sofa Cleaning', 'startColor': lightBlue, 'endColor': darkBlue},
    {'title': 'Office Cleaning', 'startColor': darkBlue, 'endColor': mediumBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'CLEANING SERVICES',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: whiteColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: buttons.map((btn) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildFullWidthButton(
                title: btn['title'],
                startColor: btn['startColor'],
                endColor: btn['endColor'],
                onTap: () {
                  // Add navigation or action here
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFullWidthButton({
    required String title,
    required Color startColor,
    required Color endColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
