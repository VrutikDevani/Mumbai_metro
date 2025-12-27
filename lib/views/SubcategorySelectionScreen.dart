import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SelectedProduct.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);
const Color blackColor = Color(0xff000000);

// New class to represent a Product Subcategory
class ProductSubcategory {
  final int subcatId;
  final String subcatName;
  final int serviceId;

  ProductSubcategory({
    required this.subcatId,
    required this.subcatName,
    required this.serviceId,
  });

  factory ProductSubcategory.fromJson(Map<String, dynamic> json) {
    return ProductSubcategory(
      subcatId: json['subcat_id'] as int,
      subcatName: json['subcat_name'] as String,
      serviceId: json['service_id'] as int,
    );
  }
}

class SubCategorySelectionScreen extends StatefulWidget {
  final int serviceId;
  final String serviceName;
  final String selectedDate;
  final String selectedTime;
  final int? customerId;
  final List<SelectedProduct> initialSelectedProducts;

  const SubCategorySelectionScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.selectedDate,
    required this.selectedTime,
    this.customerId,
    this.initialSelectedProducts = const [],
  });

  @override
  State<SubCategorySelectionScreen> createState() =>
      _SubCategorySelectionScreenState();
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

class _SubCategorySelectionScreenState
    extends State<SubCategorySelectionScreen> {
  List<ProductSubcategory> subcategories = []; // List to hold subcategories
  List<Product> products = [];
  bool isLoadingSubcategories = true; // Loading state for subcategories
  bool isLoadingProducts = false; // Loading state for products
  String? errorMessage;
  final List<SelectedProduct> selectedProducts = [];
  ProductSubcategory? selectedSubcategory; // To track the selected subcategory

  @override
  void initState() {
    super.initState();
    _fetchProductSubcategories(); // Fetch subcategories first
    selectedProducts.addAll(widget.initialSelectedProducts.map((p) =>
        SelectedProduct(
            productName: p.productName,
            count: p.count,
            productId: p.productId,
            serviceId: p.serviceId,
            productSubCatId: p.productSubCatId)));
  }

  // Fetches product subcategories based on the service ID.
  Future<void> _fetchProductSubcategories() async {
    setState(() {
      isLoadingSubcategories = true;
      errorMessage = null;
    });
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/service/${widget.serviceId}/subcategories';
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
          final List<dynamic> subcategoryData = jsonData['data'];
          setState(() {
            subcategories = subcategoryData
                .map((data) => ProductSubcategory.fromJson(data))
                .toList();
            log("selectedProducts::${subcategories.map((e) => e.subcatName).join(', ')}");
            isLoadingSubcategories = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load subcategories';
            isLoadingSubcategories = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load subcategories: ${response.statusCode}';
          isLoadingSubcategories = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching subcategories: $e';
        isLoadingSubcategories = false;
      });
    }
  }

  // Fetches products based on the selected service and subcategory IDs.
  Future<void> _fetchProducts(int subcatId) async {
    setState(() {
      isLoadingProducts = true;
      products = []; // Clear previous products
      errorMessage = null;
    });
    try {
      // As per docs: GET /api/products?service_id={service_id}&subcat_id={subcat_id}
      final String apiUrl =
          'https://54kidsstreet.org/api/products?service_id=${widget.serviceId}&subcat_id=$subcatId';
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
            isLoadingProducts = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load products';
            isLoadingProducts = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load products: ${response.statusCode}';
          isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching products: $e';
        isLoadingProducts = false;
      });
    }
  }

  void incrementProduct(Product product) {
    setState(() {
      final existingProduct = selectedProducts.firstWhere(
        (p) => p.productId == product.productId,
        orElse: () => SelectedProduct(
          productName: product.productName,
          count: 0,
          productId: product.productId,
          serviceId: product.serviceId,
          productSubCatId: selectedSubcategory!.subcatId,
        ),
      );
      if (selectedProducts.contains(existingProduct)) {
        existingProduct.count++;
      } else {
        selectedProducts.add(
          SelectedProduct(
            productName: product.productName,
            count: 1,
            productId: product.productId,
            serviceId: product.serviceId,
            productSubCatId: selectedSubcategory!.subcatId,
          ),
        );
      }
    });
  }

  void decrementProduct(Product product) {
    setState(() {
      final existingProduct = selectedProducts.firstWhere(
        (p) => p.productId == product.productId,
        orElse: () => SelectedProduct(
          productName: product.productName,
          count: 0,
          productId: product.productId,
          serviceId: product.serviceId,
          productSubCatId: selectedSubcategory!.subcatId,
        ),
      );
      if (existingProduct.count > 0) {
        existingProduct.count--;
        if (existingProduct.count == 0) {
          selectedProducts.removeWhere((p) => p.productId == product.productId);
        }
      }
    });
  }

  int getProductCount(Product product) {
    final existingProduct = selectedProducts.firstWhere(
      (p) => p.productId == product.productId,
      orElse: () => SelectedProduct(
        productName: product.productName,
        count: 0,
        productId: product.productId,
        serviceId: product.serviceId,
        productSubCatId: selectedSubcategory!.subcatId,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subcategory Section
          if (isLoadingSubcategories)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: darkBlue),
            ))
          else if (subcategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Subcategory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: subcategories.map((subcat) {
                      final isSelected =
                          selectedSubcategory?.subcatId == subcat.subcatId;
                      final hasItems = selectedProducts.any((p) =>
                          p.productSubCatId == subcat.subcatId && p.count > 0);

                      return ChoiceChip(
                        label: Text(subcat.subcatName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedSubcategory = subcat;
                            });
                            _fetchProducts(subcat.subcatId);
                          }
                        },
                        backgroundColor: isSelected
                            ? darkBlue
                            : (hasItems
                                ? const Color.fromARGB(255, 203, 135, 121)
                                : Colors.grey.shade200),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color.fromARGB(255, 30, 23, 23)
                              : (hasItems
                                  ? const Color.fromARGB(255, 35, 11, 11)
                                  : darkBlue),
                          fontFamily: 'Poppins',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: hasItems
                              ? const BorderSide(
                                  color: Color.fromARGB(255, 212, 67, 45),
                                  width: 2)
                              : BorderSide(
                                  color: isSelected
                                      ? darkBlue
                                      : Colors.grey.shade400),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Divider
          if (selectedSubcategory != null) const Divider(),

          // Products Section
          Expanded(
            child: isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(color: darkBlue))
                : errorMessage != null
                    ? Center(
                        child: Text(errorMessage!,
                            style: const TextStyle(color: darkBlue)))
                    : selectedSubcategory == null
                        ? const Center(
                            child: Text(
                                'Please select a subcategory to see products',
                                style: TextStyle(color: darkBlue)))
                        : products.isEmpty
                            ? const Center(
                                child: Text(
                                    'No inventory available for this subcategory',
                                    style: TextStyle(color: darkBlue)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final currentCount = getProductCount(product);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
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
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  decrementProduct(product),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: lightBlue,
                                                      width: 2),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            GestureDetector(
                                              onTap: () =>
                                                  incrementProduct(product),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: lightBlue,
                                                      width: 2),
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedProducts);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Next',
                        style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
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
