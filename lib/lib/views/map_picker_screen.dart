import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color mediumBlue = Color(0xFF37b3e7);

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(19.0760, 72.8777);
  LatLng _centerPosition = const LatLng(19.0760, 72.8777);
  String _currentAddress = "Loading...";
  String _detailedAddress = "";
  bool _isLoadingAddress = false;
  bool _mapLoaded = false;
  bool locationLoading = true;
  bool _locationPermissionGranted = false;
  Set<Marker> _markers = {};

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<SearchResult> _searchSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();

    // Listen to focus changes
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    if (kDebugMode) {
      print("MapPickerScreen: Checking permissions...");
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print("Location services are disabled");
      }
      setState(() {
        _currentAddress = "Location services disabled";
      });
      Fluttertoast.showToast(msg: "Please enable location services");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permission denied";
        });
        Fluttertoast.showToast(msg: "Location permission is required");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = "Location permission permanently denied";
      });
      Fluttertoast.showToast(
          msg: "Please enable location permission in settings");
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) return;

    try {
      if (kDebugMode) {
        print("Getting current location...");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print("Location found: ${position.latitude}, ${position.longitude}");
      }

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _centerPosition = _currentPosition;
      });

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 18),
          ),
        );
      }

      _getAddressFromCoordinates(_currentPosition);

      setState(() {
        locationLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      setState(() {
        _currentAddress = "Error getting location: $e";
      });
      Fluttertoast.showToast(msg: "Error getting current location");
    }
  }

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

  void _onCameraMove(CameraPosition position) {
    _centerPosition = position.target;
  }

  void _onCameraIdle() {
    if (kDebugMode) {
      print(
          "Camera idle at: ${_centerPosition.latitude}, ${_centerPosition.longitude}");
    }
    _getAddressFromCoordinates(_centerPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: locationLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () {
                // Dismiss keyboard and suggestions when tapping outside
                _searchFocusNode.unfocus();
                setState(() {
                  _showSuggestions = false;
                });
              },
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 18,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      setState(() {
                        _mapLoaded = true;
                      });
                      if (kDebugMode) {
                        print("Google Map created successfully");
                      }
                      _getAddressFromCoordinates(_currentPosition);
                    },
                    onCameraMove: _onCameraMove,
                    onCameraIdle: _onCameraIdle,
                    myLocationEnabled: _locationPermissionGranted,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    buildingsEnabled: true,
                    indoorViewEnabled: true,
                    trafficEnabled: false,
                    mapType: MapType.normal,
                    minMaxZoomPreference: const MinMaxZoomPreference(1.0, 22.0),
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    markers: _markers,
                  ),

                  // Top search bar with suggestions
                  Positioned(
                    top: 50,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black87),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: const InputDecoration(
                                    hintText: "Search here",
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    // Debounce search to avoid too many calls
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      if (_searchController.text == value) {
                                        _searchLocationSuggestions(value);
                                      }
                                    });
                                  },
                                  onSubmitted: (value) {
                                    if (_searchSuggestions.isNotEmpty) {
                                      _selectSearchResult(
                                          _searchSuggestions.first);
                                    } else {
                                      _searchLocationSuggestions(value);
                                    }
                                  },
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.black54),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchSuggestions = [];
                                      _showSuggestions = false;
                                    });
                                  },
                                ),
                              if (_isSearching)
                                const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.search,
                                      color: Colors.black54),
                                  onPressed: () {
                                    if (_searchSuggestions.isNotEmpty) {
                                      _selectSearchResult(
                                          _searchSuggestions.first);
                                    } else {
                                      _searchLocationSuggestions(
                                          _searchController.text);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),

                        // Search suggestions dropdown
                        if (_showSuggestions && _searchSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _searchSuggestions.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[200],
                              ),
                              itemBuilder: (context, index) {
                                SearchResult result = _searchSuggestions[index];
                                return ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: mediumBlue,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    result.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: result.subtitle.isNotEmpty
                                      ? Text(
                                          result.subtitle,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  onTap: () => _selectSearchResult(result),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Center pin (medium blue location marker)
                  Center(
                    child: Container(
                      height: 50,
                      width: 30,
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          color: mediumBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Control buttons
                  Positioned(
                    right: 16,
                    top: 120,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              const Icon(Icons.layers, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        if (_locationPermissionGranted)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.my_location,
                                  color: mediumBlue),
                              onPressed: _getCurrentLocation,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Loading indicator when map is loading
                  if (!_mapLoaded)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Loading Map..."),
                          ],
                        ),
                      ),
                    ),

                  // Bottom address card
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: mediumBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_isLoadingAddress)
                                            const Row(
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                ),
                                                SizedBox(width: 8),
                                                Text("Getting address..."),
                                              ],
                                            )
                                          else ...[
                                            Text(
                                              _currentAddress,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (_detailedAddress
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                _detailedAddress,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print(
                                            "Adding location: $_centerPosition");
                                        print("Address: $_currentAddress");
                                      }
                                      String fullAddress = _currentAddress;
                                      if (_detailedAddress.isNotEmpty) {
                                        fullAddress += ", $_detailedAddress";
                                      }
                                      Navigator.pop(context, {
                                        'coordinates': _centerPosition,
                                        'address': fullAddress,
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: mediumBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Model class for search results
class SearchResult {
  final String title;
  final String subtitle;
  final LatLng location;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.location,
  });
}
