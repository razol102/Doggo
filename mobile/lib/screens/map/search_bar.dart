import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/app_colors.dart';

class PlaceSearchBar extends StatelessWidget {
  final Function(LatLng, String) onSearch;

  PlaceSearchBar({Key? key, required this.onSearch}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();
  final String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<String>> _getSuggestions(String query) async {
    final response = await http.get(Uri.parse('$_nominatimUrl?format=json&q=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => e['display_name'] as String).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void _searchPlace(String place) async {
    final response = await http.get(Uri.parse('$_nominatimUrl?format=json&q=$place'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        final location = data.first;
        final lat = double.parse(location['lat']);
        final lon = double.parse(location['lon']);
        onSearch(LatLng(lat, lon), place);
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TypeAheadField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for a place',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              fillColor: AppColors.whiteColor.withOpacity(0.7),
              filled: true,
            ),
          ),
          suggestionsCallback: (pattern) async {
            return await _getSuggestions(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(title: Text(suggestion));
          },
          onSuggestionSelected: (suggestion) {
            _searchPlace(suggestion);
          },
        ),
      ),
    );
  }
}