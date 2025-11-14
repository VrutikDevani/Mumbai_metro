import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_packers_application/lib/constant/app_formatter.dart';
import '../../models/ShiftData.dart';
import '../../views/ACServicesScreen.dart' as AppColor;
import '../../views/ServiceSelectionScreen.dart';
import '../../views/YourFinalScreen.dart';
import 'map_picker_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color whiteColor = Color(0xFFf7f7f7);
const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);

class LocationSelectionScreen extends StatefulWidget {
  final ShiftData shiftData;
  final bool navigateToInventory;

  const LocationSelectionScreen({
    Key? key,
    required this.shiftData,
    this.navigateToInventory = false,
  }) : super(key: key);

  @override
  _LocationSelectionScreenState createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _sourceLocalityController =
      TextEditingController();
  final TextEditingController _destinationLocalityController =
      TextEditingController();
  // bool _normalLiftSource = false;
  bool _serviceLiftSource = false;
  int _floorSource = 0;
  // bool _normalLiftDestination = false;
  bool _serviceLiftDestination = false;
  int _floorDestination = 0;

  String selectedDate = '';
  String selectedTime = '';
  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    // _normalLiftSource = widget.shiftData.normalLiftSource;
    _serviceLiftSource = widget.shiftData.serviceLiftSource;
    _floorSource = widget.shiftData.floorSource;
    // _normalLiftDestination = widget.shiftData.normalLiftDestination;
    _serviceLiftDestination = widget.shiftData.serviceLiftDestination;
    _floorDestination = widget.shiftData.floorDestination;
    _sourceLocalityController.text = widget.shiftData.sourceAddress ?? '';
    _destinationLocalityController.text =
        widget.shiftData.destinationAddress ?? '';
    selectedDate = widget.shiftData.selectedDate;
    selectedTime = widget.shiftData.selectedTime;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mediumBlue,
              onPrimary: whiteColor,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = AppFormatter.dateFormater(
          date: picked.toIso8601String().split('T').first,
        );
        widget.shiftData.selectedDate = AppFormatter.dateFormater(
          date: picked.toIso8601String().split('T').first,
        );
      });
    }
  }

  Future<void> _pickLocation(bool isSource) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        if (isSource) {
          _sourceLocalityController.text =
              result['address'] ?? 'Unknown location';
          widget.shiftData.sourceCoordinates = result['coordinates'];
          widget.shiftData.sourceAddress = result['address'];
        } else {
          _destinationLocalityController.text =
              result['address'] ?? 'Unknown location';
          widget.shiftData.destinationCoordinates = result['coordinates'];
          widget.shiftData.destinationAddress = result['address'];
        }
      });
      Fluttertoast.showToast(msg: "Location selected successfully");
    } else {
      Fluttertoast.showToast(msg: "No location selected");
    }
  }

  //New for search direct
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<SearchResult> _searchSuggestions = [];
  bool _showSuggestions = false;
  LatLng _centerPosition = const LatLng(19.0760, 72.8777);

  GoogleMapController? _mapController;

  Future<void> _searchLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      List<SearchResult> allSuggestions = [];
      Set<String> uniqueLocations = {}; // To avoid duplicates

      // Generate multiple search variations to get more results
      List<String> searchQueries = [
        query,
        "$query, India",
        "$query, Maharashtra",
        "$query Railway Station",
        "$query Airport",
        "$query Beach",
        "$query Market",
        "$query Mall",
        "Mumbai $query",
        "Thane $query",
        "Navi Mumbai $query",
      ];

      if (kDebugMode) {
        print("Searching for: $query");
      }

      // Search with multiple queries
      for (String searchQuery in searchQueries) {
        try {
          List<Location> locations = await locationFromAddress(searchQuery);

          if (kDebugMode) {
            print("Found ${locations.length} locations for: $searchQuery");
          }

          // Process each location
          for (Location loc in locations) {
            try {
              // Get detailed information
              List<Placemark> placemarks = await placemarkFromCoordinates(
                loc.latitude,
                loc.longitude,
                localeIdentifier: "en_IN",
              );

              if (placemarks.isNotEmpty) {
                Placemark place = placemarks[0];

                // Build title
                String title = "";
                if (place.name != null && place.name!.isNotEmpty) {
                  title = place.name!;
                } else if (place.locality != null &&
                    place.locality!.isNotEmpty) {
                  title = place.locality!;
                } else if (place.subLocality != null &&
                    place.subLocality!.isNotEmpty) {
                  title = place.subLocality!;
                } else if (place.administrativeArea != null &&
                    place.administrativeArea!.isNotEmpty) {
                  title = place.administrativeArea!;
                }

                // Build subtitle
                List<String> subtitleParts = [];
                if (place.subLocality != null &&
                    place.subLocality!.isNotEmpty &&
                    place.subLocality != title) {
                  subtitleParts.add(place.subLocality!);
                }
                if (place.locality != null &&
                    place.locality!.isNotEmpty &&
                    place.locality != title) {
                  subtitleParts.add(place.locality!);
                }
                if (place.administrativeArea != null &&
                    place.administrativeArea!.isNotEmpty &&
                    place.administrativeArea != title) {
                  subtitleParts.add(place.administrativeArea!);
                }
                if (place.country != null && place.country!.isNotEmpty) {
                  subtitleParts.add(place.country!);
                }

                String subtitle = subtitleParts.join(", ");

                // Create unique key to avoid duplicates
                String uniqueKey =
                    "${loc.latitude.toStringAsFixed(4)},${loc.longitude.toStringAsFixed(4)}-${title.toLowerCase()}";

                if (!uniqueLocations.contains(uniqueKey) && title.isNotEmpty) {
                  uniqueLocations.add(uniqueKey);
                  allSuggestions.add(SearchResult(
                    title: title,
                    subtitle: subtitle.isNotEmpty ? subtitle : "India",
                    location: LatLng(loc.latitude, loc.longitude),
                  ));

                  if (kDebugMode) {
                    print("Added suggestion: $title - $subtitle");
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print("Error processing location: $e");
              }
            }

            // Limit results to avoid too many API calls
            if (allSuggestions.length >= 15) break;
          }

          if (allSuggestions.length >= 15) break;
        } catch (e) {
          if (kDebugMode) {
            print("Error searching '$searchQuery': $e");
          }
          continue;
        }

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Sort by relevance (locations that contain the search query first)
      allSuggestions.sort((a, b) {
        bool aContains = a.title.toLowerCase().contains(query.toLowerCase());
        bool bContains = b.title.toLowerCase().contains(query.toLowerCase());
        if (aContains && !bContains) return -1;
        if (!aContains && bContains) return 1;
        return 0;
      });

      // Limit to top 10 results
      List<SearchResult> finalSuggestions = allSuggestions.take(10).toList();

      if (kDebugMode) {
        print("Total unique suggestions: ${finalSuggestions.length}");
      }

      setState(() {
        _searchSuggestions = finalSuggestions;
        _isSearching = false;
      });

      if (finalSuggestions.isEmpty) {
        Fluttertoast.showToast(msg: "No locations found for '$query'");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Search error: $e");
      }
      setState(() {
        _searchSuggestions = [];
        _isSearching = false;
      });
      Fluttertoast.showToast(msg: "Error searching location");
    }
  }

  void _selectSearchResult(SearchResult result) {
    setState(() {
      _centerPosition = result.location;
      _showSuggestions = false;
      _searchController.text = result.title;
    });

    _searchFocusNode.unfocus();

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: result.location, zoom: 18),
        ),
      );
    }

    _getAddressFromCoordinates(result.location);
  }

  String _currentAddress = "Loading...";
  String _detailedAddress = "";
  bool _isLoadingAddress = false;


  Future<void> _getAddressFromCoordinates(LatLng position) async {
    if (_isLoadingAddress) return;

    setState(() {
      _isLoadingAddress = true;
      _currentAddress = "Getting address...";
    });

    try {
      if (kDebugMode) {
        print(
            "Getting address for: ${position.latitude}, ${position.longitude}");
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "en_IN",
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        if (kDebugMode) {
          print("Address found: $place");
        }

        // Build main address (like "C/209, Raheja Vihar Circular Road")
        List<String> mainAddressParts = [];
        if (place.name != null && place.name!.isNotEmpty) {
          mainAddressParts.add(place.name!);
        }
        if (place.street != null &&
            place.street!.isNotEmpty &&
            place.street != place.name) {
          mainAddressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          mainAddressParts.add(place.subLocality!);
        }

        String mainAddress = mainAddressParts.isNotEmpty
            ? mainAddressParts.join(", ")
            : (place.locality ?? "Unknown location");

        // Build detailed address (like "Kandivali East, Mumbai, Maharashtra 400101")
        List<String> detailedParts = [];
        if (place.locality != null && place.locality!.isNotEmpty) {
          detailedParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          detailedParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          detailedParts.add(place.postalCode!);
        }

        String detailed =
        detailedParts.isNotEmpty ? detailedParts.join(", ") : "";

        setState(() {
          _currentAddress = mainAddress;
          _detailedAddress = detailed;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _currentAddress = "Unknown location";
          _detailedAddress =
          "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting address: $e");
      }
      setState(() {
        _currentAddress = "Unknown location";
        _detailedAddress =
        "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasBanner = widget.shiftData.categoryBannerImg != null &&
        widget.shiftData.categoryBannerImg!.isNotEmpty;
    bool hasDescription = widget.shiftData.categoryDesc != null &&
        widget.shiftData.categoryDesc!.isNotEmpty;
    bool showBannerSection = hasBanner || hasDescription;
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBannerSection)
                    Container(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasBanner)
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColor.lightBlue,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/parcelwala4.jpg',
                                  image:
                                      'https://54kidsstreet.org/admin_assets/category_banner_img/${widget.shiftData.categoryBannerImg}',
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/parcelwala4.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (hasBanner && hasDescription)
                            const SizedBox(height: 8),
                          if (hasDescription)
                            Text(
                              widget.shiftData.categoryDesc!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  const Text(
                    'When to shift?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            selectedDate.isEmpty ? 'Select date' : selectedDate,
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Select time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          value: selectedTime.isEmpty ? null : selectedTime,
                          items: timeSlots.map((String time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child:
                                  Text(time, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedTime = newValue;
                                widget.shiftData.selectedTime = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Source',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Locality'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _sourceLocalityController,
                    readOnly: true,
                    onTap: () => _pickLocation(true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Tap to select source location',
                      suffixIcon:
                          const Icon(Icons.location_on, color: mediumBlue),
                    ),
                  ),
                  // Container(
                  //   height: 50,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(25),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2),
                  //         blurRadius: 8,
                  //         offset: const Offset(0, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: TextField(
                  //           controller: _searchController,
                  //           focusNode: _searchFocusNode,
                  //           decoration: const InputDecoration(
                  //             hintText: "Search here",
                  //             border: InputBorder.none,
                  //             contentPadding:
                  //             EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  //           ),
                  //           onChanged: (value) {
                  //             // Debounce search to avoid too many calls
                  //             Future.delayed(
                  //                 const Duration(milliseconds: 500), () {
                  //               if (_searchController.text == value) {
                  //                 _searchLocationSuggestions(value);
                  //               }
                  //             });
                  //           },
                  //           onSubmitted: (value) {
                  //             if (_searchSuggestions.isNotEmpty) {
                  //               _selectSearchResult(
                  //                   _searchSuggestions.first);
                  //             } else {
                  //               _searchLocationSuggestions(value);
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //       if (_searchController.text.isNotEmpty)
                  //         IconButton(
                  //           icon: const Icon(Icons.clear,
                  //               color: Colors.black54),
                  //           onPressed: () {
                  //             _searchController.clear();
                  //             setState(() {
                  //               _searchSuggestions = [];
                  //               _showSuggestions = false;
                  //             });
                  //           },
                  //         ),
                  //       if (_isSearching)
                  //         const Padding(
                  //           padding: EdgeInsets.all(12.0),
                  //           child: SizedBox(
                  //             width: 20,
                  //             height: 20,
                  //             child: CircularProgressIndicator(
                  //                 strokeWidth: 2),
                  //           ),
                  //         )
                  //       else
                  //         IconButton(
                  //           icon: const Icon(Icons.search,
                  //               color: Colors.black54),
                  //           onPressed: () {
                  //             if (_searchSuggestions.isNotEmpty) {
                  //               _selectSearchResult(
                  //                   _searchSuggestions.first);
                  //             } else {
                  //               _searchLocationSuggestions(
                  //                   _searchController.text);
                  //             }
                  //           },
                  //         ),
                  //     ],
                  //   ),
                  // ),
                  // if (_showSuggestions && _searchSuggestions.isNotEmpty)
                  //   Container(
                  //     margin: const EdgeInsets.only(top: 8),
                  //     constraints: BoxConstraints(
                  //       maxHeight:
                  //       MediaQuery.of(context).size.height * 0.4,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.2),
                  //           blurRadius: 8,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: ListView.separated(
                  //       shrinkWrap: true,
                  //       padding: const EdgeInsets.symmetric(vertical: 8),
                  //       itemCount: _searchSuggestions.length,
                  //       separatorBuilder: (context, index) => Divider(
                  //         height: 1,
                  //         color: Colors.grey[200],
                  //       ),
                  //       itemBuilder: (context, index) {
                  //         SearchResult result = _searchSuggestions[index];
                  //         return ListTile(
                  //           leading: Container(
                  //             width: 40,
                  //             height: 40,
                  //             decoration: BoxDecoration(
                  //               color: Colors.grey[100],
                  //               shape: BoxShape.circle,
                  //             ),
                  //             child: Icon(
                  //               Icons.location_on,
                  //               color: mediumBlue,
                  //               size: 20,
                  //             ),
                  //           ),
                  //           title: Text(
                  //             result.title,
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.w500,
                  //               color: Colors.black87,
                  //             ),
                  //             maxLines: 1,
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //           subtitle: result.subtitle.isNotEmpty
                  //               ? Text(
                  //             result.subtitle,
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.grey[600],
                  //             ),
                  //             maxLines: 1,
                  //             overflow: TextOverflow.ellipsis,
                  //           )
                  //               : null,
                  //           onTap: () => _selectSearchResult(result),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // const SizedBox(height: 8),
                  // CheckboxListTile(
                  //   title: const Text('Normal Lift Available'),
                  //   value: _normalLiftSource,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _normalLiftSource = value!;
                  //       widget.shiftData.normalLiftSource = value;
                  //     });
                  //   },
                  //   controlAffinity: ListTileControlAffinity.trailing,
                  // ),
                  CheckboxListTile(
                    title: const Text('Lift Available'),
                    value: _serviceLiftSource,
                    onChanged: (value) {
                      setState(() {
                        _serviceLiftSource = value!;
                        widget.shiftData.serviceLiftSource = value;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Floor',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: mediumBlue),
                            onPressed: _floorSource > 0
                                ? () => setState(() {
                                      _floorSource--;
                                      widget.shiftData.floorSource =
                                          _floorSource;
                                    })
                                : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              _floorSource.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: mediumBlue),
                            onPressed: () => setState(() {
                              _floorSource++;
                              widget.shiftData.floorSource = _floorSource;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Destination',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Locality'),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _destinationLocalityController,
                    readOnly: true,
                    onTap: () => _pickLocation(false),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Tap to select destination location',
                      suffixIcon:
                          const Icon(Icons.location_on, color: mediumBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // CheckboxListTile(
                  //   title: const Text('Normal Lift Available'),
                  //   value: _normalLiftDestination,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _normalLiftDestination = value!;
                  //       widget.shiftData.normalLiftDestination = value;
                  //     });
                  //   },
                  //   controlAffinity: ListTileControlAffinity.trailing,
                  // ),
                  CheckboxListTile(
                    title: const Text('Lift Available'),
                    value: _serviceLiftDestination,
                    onChanged: (value) {
                      setState(() {
                        _serviceLiftDestination = value!;
                        widget.shiftData.serviceLiftDestination = value;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Floor',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: mediumBlue),
                            onPressed: _floorDestination > 0
                                ? () => setState(() {
                                      _floorDestination--;
                                      widget.shiftData.floorDestination =
                                          _floorDestination;
                                    })
                                : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              _floorDestination.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: mediumBlue),
                            onPressed: () => setState(() {
                              _floorDestination++;
                              widget.shiftData.floorDestination =
                                  _floorDestination;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDate.isEmpty || selectedTime.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select date and time'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_sourceLocalityController.text.isEmpty ||
                      _destinationLocalityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select both source and destination locations'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  widget.shiftData.floorSource = _floorSource;
                  widget.shiftData.floorDestination = _floorDestination;
                  widget.shiftData.selectedDate = selectedDate;
                  widget.shiftData.selectedTime = selectedTime;

                  // Navigate to inventory screen if coming from subcategory
                  if (widget.navigateToInventory) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceSelectionScreen(
                          subCategoryId: widget.shiftData.subCategoryId ?? 0,
                          subCategoryName: widget.shiftData.serviceName,
                          customerId: widget.shiftData.customerId,
                          // categoryBannerImg: widget.shiftData.categoryBannerImg,
                          // categoryDesc: widget.shiftData.categoryDesc,
                          shiftData: widget.shiftData,
                        ),
                      ),
                    );
                  } else {
                    // Original navigation to YourFinalScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            YourFinalScreen(shiftData: widget.shiftData),
                      ),
                    );
                  }
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
        ],
      ),
    );
  }
}
