import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ShiftData.dart';
import 'SelectedProduct.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class ProductSelectionScreen extends StatefulWidget {
  final int serviceId;
  final String serviceName;
  final String selectedDate;
  final String selectedTime;
  final int? customerId; // Added customerId parameter
  final List<SelectedProduct> initialSelectedProducts;

  const ProductSelectionScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.selectedDate,
    required this.selectedTime,
    this.customerId, // Added customerId parameter
    this.initialSelectedProducts = const [],
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class Product {
  final int productId;
  final int serviceId;
  final String productName;
  final String productCft;

  Product({
    required this.productId,
    required this.serviceId,
    required this.productName,
    required this.productCft,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      serviceId: json['service_id'] as int,
      productName: json['product_name'] as String,
      productCft: json['product_cft'] as String,
    );
  }
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;
  final List<SelectedProduct> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    selectedProducts.addAll(widget.initialSelectedProducts.map(
        (p) => SelectedProduct(productName: p.productName, count: p.count)));
  }

  Future<void> _fetchProducts() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/Product/${widget.serviceId}';
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
          final List<dynamic> productData = jsonData['data'];
          setState(() {
            products =
                productData.map((data) => Product.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load products';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load products: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching products: $e';
        isLoading = false;
      });
    }
  }

  void incrementProduct(String productName) {
    setState(() {
      final existingProduct = selectedProducts.firstWhere(
        (p) => p.productName == productName,
        orElse: () => SelectedProduct(productName: productName, count: 0),
      );
      if (selectedProducts.contains(existingProduct)) {
        existingProduct.count++;
      } else {
        selectedProducts
            .add(SelectedProduct(productName: productName, count: 1));
      }
    });
  }

  void decrementProduct(String productName) {
    setState(() {
      final existingProduct = selectedProducts.firstWhere(
        (p) => p.productName == productName,
        orElse: () => SelectedProduct(productName: productName, count: 0),
      );
      if (existingProduct.count > 0) {
        existingProduct.count--;
        if (existingProduct.count == 0) {
          selectedProducts.removeWhere((p) => p.productName == productName);
        }
      }
    });
  }

  int getProductCount(String productName) {
    final existingProduct = selectedProducts.firstWhere(
      (p) => p.productName == productName,
      orElse: () => SelectedProduct(productName: productName, count: 0),
    );
    return existingProduct.count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          '${widget.serviceName} Inventory',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () {
            Navigator.pop(context, selectedProducts);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: darkBlue))
                : errorMessage != null
                    ? Center(
                        child: Text(errorMessage!,
                            style: const TextStyle(color: darkBlue)))
                    : products.isEmpty
                        ? const Center(
                            child: Text('No inventory available',
                                style: TextStyle(color: darkBlue)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final currentCount =
                                  getProductCount(product.productName);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.productName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => decrementProduct(
                                              product.productName),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: lightBlue, width: 2),
                                            ),
                                            child: const Icon(Icons.remove,
                                                color: lightBlue, size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade100,
                                          ),
                                          child: Center(
                                            child: Text(
                                              currentCount.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => incrementProduct(
                                              product.productName),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: lightBlue, width: 2),
                                            ),
                                            child: const Icon(Icons.add,
                                                color: lightBlue, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedProducts);
                      },
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
                          color: whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
