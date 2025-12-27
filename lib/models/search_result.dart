import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchResult {
  final String title;
  final String subtitle;
  final LatLng? location;
  final String? placeId;

  SearchResult({
    required this.title,
    required this.subtitle,
    this.location,
    this.placeId,
  });
}
