import 'package:flutter/material.dart';

class PartnerSuccessScreen extends StatelessWidget {
  final Map<String, String> formData;

  const PartnerSuccessScreen({super.key, required this.formData});
  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);
  static const Color whiteColor = Color(0xFFf7f7f7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Submission Successful',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green checkmark icon
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
              ),
              const SizedBox(height: 20),
              // Success message
              const Center(
                child: Text(
                  'Your Partnership Request\nSubmitted Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Submitted details
              const Text(
                'Submitted Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${formData['name']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('Company Name: ${formData['companyName']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('City: ${formData['city']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('Email: ${formData['email']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('Phone: ${formData['phone']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('Website: ${formData['website']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('Service Type: ${formData['serviceType']}', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Additional message
              const Center(
                child: Text(
                  'We have received your details.\nOur team will contact you soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Back to Home button
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // "you soo..." text
              const Center(
                child: Text(
                  'you soo...',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}