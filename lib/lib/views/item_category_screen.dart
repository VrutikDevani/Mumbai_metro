import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../views/next_button.dart';
import '../viewmodels/shift_house_viewmodel.dart';
import 'item_detail_screen.dart';
import 'location_selection_screen.dart';
import '../../models/ShiftData.dart'; // Import ShiftData

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class ItemCategoryScreen extends StatelessWidget {
  const ItemCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShiftHouseViewModel>(
      builder: (context, viewModel, child) {
        // Calculate total products from item counts
        int totalProducts = viewModel.itemCategories.fold(0, (sum, category) {
          return sum + viewModel.getTotalItemsInCategory(category.name);
        });

        return Scaffold(
          backgroundColor: whiteColor,
          appBar: AppBar(
            title: const Text(
              'Shift My House',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            backgroundColor: darkBlue,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: viewModel.itemCategories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.itemCategories[index];
                    final totalCount = viewModel.getTotalItemsInCategory(category.name);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                          color: mediumBlue,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (category.items.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider.value(
                                    value: viewModel,
                                    child: ItemDetailScreen(category: category),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  '${category.icon} ${category.name} ${category.icon}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (totalCount > 0)
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        totalCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              NextButton(
                totalProducts: totalProducts, // Required by NextButton constructor
                selectedDate: viewModel.shiftHouseData.selectedDate, // Required by NextButton constructor
                selectedTime: viewModel.shiftHouseData.selectedTime, // Required by NextButton constructor
                onPressed: () {
                  // Validation: Check if date and time are selected
                  if (viewModel.shiftHouseData.selectedDate.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a date'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (viewModel.shiftHouseData.selectedTime.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a time'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validation: Check if at least one item is selected
                  bool hasSelectedItems = false;
                  for (var category in viewModel.itemCategories) {
                    if (viewModel.getTotalItemsInCategory(category.name) > 0) {
                      hasSelectedItems = true;
                      break;
                    }
                  }

                  if (!hasSelectedItems) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one item to move'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create ShiftData instance
                  final shiftData = ShiftData(
                    serviceId: 0, // Placeholder; replace with actual serviceId if available
                    serviceName: 'Shift My House', // Placeholder; replace with actual serviceName if available
                    selectedDate: viewModel.shiftHouseData.selectedDate,
                    selectedTime: viewModel.shiftHouseData.selectedTime,
                    selectedProducts: viewModel.getSelectedProducts(), // Now implemented
                  );

                  // Navigate to LocationSelectionScreen with ShiftData
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationSelectionScreen(
                        shiftData: shiftData,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}