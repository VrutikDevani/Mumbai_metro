// lib/views/ThankYouScreen.dart
import 'package:flutter/material.dart';
import 'package:new_packers_application/lib/constant/app_formatter.dart';
import '../lib/payment_service/payment_service.dart';
import '../models/ServiceEnquiryData.dart';
import 'HomeServiceView.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class BookingConfirmationWithAmount extends StatefulWidget {
  final ServiceEnquiryResponse serviceResponse;

  const BookingConfirmationWithAmount(
      {super.key, required this.serviceResponse});

  @override
  State<BookingConfirmationWithAmount> createState() =>
      _BookingConfirmationWithAmountState();
}

class _BookingConfirmationWithAmountState
    extends State<BookingConfirmationWithAmount> {
  @override
  Widget build(BuildContext context) {
    double calculatePercentage(double amount) {
      return amount * (10 / 100);
    }

    double calculateTotalAmount(double amount, double addingAmount) {
      return amount + addingAmount;
    }

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Booking Confirmation',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // Text(
              //   serviceResponse.msg,
              //   style: const TextStyle(
              //     fontSize: 18,
              //     color: darkBlue,
              //     fontFamily: 'Poppins',
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 30),
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(15),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.2),
              //         spreadRadius: 2,
              //         blurRadius: 8,
              //         offset: const Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text(
              //         'Service Details:',
              //         style: TextStyle(
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //           color: darkBlue,
              //           fontFamily: 'Poppins',
              //         ),
              //       ),
              //       const SizedBox(height: 15),
              //       _buildDetailRow('User ID:', serviceResponse.data?.customerId ?? 'N/A'),
              //       _buildDetailRow('Order Number:', '#${serviceResponse.data?.orderNo ?? 'N/A'}'),
              //       _buildDetailRow('Service Name:', serviceResponse.data?.serviceName ?? 'N/A'),
              //       _buildDetailRow('Service Date:', serviceResponse.data?.serviceDate ?? 'N/A'),
              //       _buildDetailRow('Location:', serviceResponse.data?.serviceLocation ?? 'N/A'),
              //       _buildDetailRow('Flat Number:', serviceResponse.data?.flatNo ?? 'N/A'),
              //       _buildDetailRow('Description:', serviceResponse.data?.serviceDescription ?? 'N/A'),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 15),
              Text(
                'Your Estimate : ${widget.serviceResponse.data?.amount ?? 0}',
                style: const TextStyle(
                  fontSize: 18,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Includes door to door delivery with packing,transportation,loading & unloading.',
                style: const TextStyle(
                  fontSize: 18,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Book your slot by paying only 10% of total estimate : ${calculatePercentage(double.parse((widget.serviceResponse.data?.amount ?? 0).toString()))}.',
                style: const TextStyle(
                  fontSize: 18,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Total amount to pay : ${calculateTotalAmount(double.parse((widget.serviceResponse.data?.amount ?? 0).toString()), calculatePercentage(double.parse((widget.serviceResponse.data?.amount ?? 0).toString())))}.',
                style: const TextStyle(
                  fontSize: 18,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomeServiceView()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mediumBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Book Later',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // PaymentService().startPayment(context,
                          //     amount: calculateTotalAmount(
                          //         double.parse(
                          //             (widget.serviceResponse.data?.amount ?? 0)
                          //                 .toString()),
                          //         calculatePercentage(double.parse(
                          //             (widget.serviceResponse.data?.amount ?? 0)
                          //                 .toString()))),
                          //     name: 'User',orderNumber: (widget.serviceResponse.data?.orderNo??'').toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'QR screen',
                                style: TextStyle(
                                    fontFamily: 'Poppins', color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Navigator.pushReplacement(
                          //   context,
                          // MaterialPageRoute(
                          //   builder: (context) => EnquiryThankYouScreen(enquiryResponse: response),
                          // ),
                          // MaterialPageRoute(
                          //   builder: (context) => EnquiryThankYouScreen(
                          //       enquiryResponse: widget.enquiryResponse),
                          // ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mediumBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThankYouScreen extends StatelessWidget {
  final ServiceEnquiryResponse serviceResponse;
  bool showAmountScreen;

  ThankYouScreen({
    super.key,
    required this.serviceResponse,
    required this.showAmountScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your enquiry submitted successfully',
                style: const TextStyle(
                  fontSize: 16,
                  color: darkBlue,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enquiry Details:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                        'User ID:', serviceResponse.data?.customerId ?? 'N/A'),
                    _buildDetailRow('Order Number:',
                        '#${serviceResponse.data?.orderNo ?? 'N/A'}'),
                    _buildDetailRow('Service Name:',
                        serviceResponse.data?.serviceName ?? 'N/A'),
                    serviceResponse.data?.flatNo == '0'
                        ? SizedBox()
                        : _buildDetailRow('Flat Number:',
                            serviceResponse.data?.flatNo ?? 'N/A'),
                    if (serviceResponse.data?.destinationLocation == null ||
                        serviceResponse.data?.destinationLocation ==
                            'NONE') ...[
                      _buildDetailRow('Location:',
                          serviceResponse.data?.serviceLocation ?? 'N/A'),
                    ],
                    if (serviceResponse.data?.destinationLocation != null &&
                        serviceResponse.data?.destinationLocation !=
                            'NONE') ...[
                      _buildDetailRow('Pickup Location:',
                          serviceResponse.data?.serviceLocation ?? 'N/A'),
                      _buildDetailRow('Destination Location:',
                          serviceResponse.data?.destinationLocation ?? 'N/A'),
                    ],
                    serviceResponse.data?.vehicleDetails != ''
                        ? _buildDetailRow('Vehicle:',
                            serviceResponse.data?.vehicleDetails ?? 'N/A')
                        : SizedBox(),
                    if (serviceResponse.data?.notes != null &&
                        serviceResponse.data?.notes !=
                            '') ...[
                      _buildDetailRow('Notes:',
                          serviceResponse.data?.notes ?? 'N/A'),
                    ],
                    _buildDetailRow(
                      'Service Date:',
                      AppFormatter.dateFormater(
                          date: serviceResponse.data?.serviceDate ?? 'N/A'),
                    ),
                    _buildDetailRow(
                      'Created Date:',
                      AppFormatter.dateFormater(
                          date: serviceResponse.data?.createdAt ?? 'N/A'),
                    ),
                    serviceResponse.data?.serviceDescription != 'NONE'
                        ? _buildDetailRow('Description:',
                            serviceResponse.data?.serviceDescription ?? 'N/A')
                        : SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Our team will contact you soon to confirm your service request. Thank you for choosing Mumbai Metro Packers and Movers!',
                  style: TextStyle(
                    fontSize: 14,
                    color: darkBlue,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              // SizedBox(
              //   width: double.infinity,
              //   height: 50,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).pushAndRemoveUntil(
              //         MaterialPageRoute(builder: (context) => const HomeServiceView()),
              //             (Route<dynamic> route) => false,
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: mediumBlue,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //     ),
              //     child: const Text(
              //       'Back to Home',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //         color: whiteColor,
              //         fontFamily: 'Poppins',
              //       ),
              //     ),
              //   ),
              // ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (showAmountScreen) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingConfirmationWithAmount(
                              serviceResponse: serviceResponse),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomeServiceView()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mediumBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    showAmountScreen ? 'NEXT' : 'BACK HOME',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: darkBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
