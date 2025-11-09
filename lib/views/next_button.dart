import 'package:flutter/material.dart';

const Color darkBlue = Color(0xFF03669d);

class NextButton extends StatelessWidget {
  final int totalProducts;
  final String selectedDate;
  final String selectedTime;
  final VoidCallback? onPressed;

  const NextButton({
    super.key,
    required this.totalProducts,
    required this.selectedDate,
    required this.selectedTime,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}