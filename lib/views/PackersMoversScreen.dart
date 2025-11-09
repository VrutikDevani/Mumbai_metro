import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/viewmodels/shift_house_viewmodel.dart';
import '/views/shift_house_screen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class PackersMoversScreen extends StatelessWidget {
  const PackersMoversScreen({super.key});

  final List<Map<String, dynamic>> buttons = const [
    {'title': 'Local Shifting', 'startColor': darkBlue, 'endColor': lightBlue},
    {'title': 'Domestic Shifting', 'startColor': mediumBlue, 'endColor': darkBlue},
    {'title': 'International Shifting', 'startColor': lightBlue, 'endColor': mediumBlue},
    {'title': 'Office Shifting', 'startColor': darkBlue, 'endColor': mediumBlue},
    {'title': 'Vehicle Transport', 'startColor': mediumBlue, 'endColor': lightBlue},
    {'title': 'Storage Transport', 'startColor': lightBlue, 'endColor': darkBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'PACKERS AND MOVERS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
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
                  // ✅ Navigate to ShiftHouseScreen for all options
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => ShiftHouseViewModel(),
                        child: const ShiftHouseScreen(),
                      ),
                    ),
                  );
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
