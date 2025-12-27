import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/google_places_service.dart';

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(SearchResult) onLocationSelected;
  final String hintText;

  const LocationAutocompleteField({
    Key? key,
    required this.controller,
    required this.onLocationSelected,
    this.label = 'Society / Area',
    this.hintText = 'Search Society / Area',
  }) : super(key: key);

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  // TODO: Replace with your API key
  final _placesService =
      GooglePlacesService(apiKey: 'AIzaSyD89e_jQ_xoTxPKqwkks0Z0PbtPCNkHKaE');

  bool _isSearching = false;
  List<SearchResult> _searchSuggestions = [];
  bool _showSuggestions = false;

  Future<void> _searchLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchSuggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isSearching = true;
          _showSuggestions = true;
        });
      }

      final predictions = await _placesService.autocomplete(query);

      List<SearchResult> allSuggestions = predictions
          .map((p) => SearchResult(
                title: p.mainText.isNotEmpty ? p.mainText : p.description,
                subtitle: p.secondaryText,
                placeId: p.placeId,
                location: null,
              ))
          .toList();

      if (mounted) {
        setState(() {
          _searchSuggestions = allSuggestions;
          _showSuggestions = allSuggestions.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint("Error searching location: $e");
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchSuggestions = [];
        });
      }
    }
  }

  Future<void> _selectSearchResult(SearchResult result) async {
    widget.controller.text = result.title + "," + result.subtitle;

    // Hide suggestions immediately
    setState(() {
      _showSuggestions = false;
      _searchSuggestions = [];
    });

    if (result.placeId != null) {
      try {
        final latLng = await _placesService.getPlaceDetails(result.placeId!);
        if (latLng != null) {
          final fullResult = SearchResult(
              title: result.title,
              subtitle: result.subtitle,
              placeId: result.placeId,
              location: latLng);

          widget.onLocationSelected(fullResult);
        }
      } catch (e) {
        debugPrint("Error fetching details: $e");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: (value) {
            if (mounted) {
              // Simple debounce
              Future.delayed(const Duration(milliseconds: 500), () {
                if (widget.controller.text == value) {
                  _searchLocationSuggestions(value);
                }
              });
            }
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: const Color(0xFFf7f7f7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF37b3e7)),
                borderRadius: BorderRadius.circular(10)),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search, color: Color(0xFF37b3e7)),
          ),
        ),
        if (_showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFf7f7f7),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 4,
                      blurRadius: 4,
                      offset: Offset(0, 0))
                ]),
            child: _searchSuggestions.isEmpty && !_isSearching
                ? const SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchSuggestions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = _searchSuggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined,
                                  color: Colors.grey),
                              title: Text(
                                suggestion.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: suggestion.subtitle.isNotEmpty
                                  ? Text(suggestion.subtitle)
                                  : null,
                              onTap: () => _selectSearchResult(suggestion),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("powered by ",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                            // Using text here as I don't have the google logo asset handy,
                            // but usually there's a specific asset for this.
                            const Text("Google",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}
