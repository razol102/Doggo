import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../services/http_service.dart';
import '../../utils/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  LatLng _currentPosition = LatLng(32.0853, 34.7818); // Default position in Tel Aviv

  final TextEditingController _searchController = TextEditingController();
  final String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    await _updateUserLocation();
  }

  void _rotateToNorth() {
    _mapController.rotate(0);
  }

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 14.0);

        _markers.removeWhere((marker) => marker.key == Key('userLocation'));

        _markers.add(
          Marker(
            key: Key('userLocation'),
            point: _currentPosition,
            child: Icon(
              Icons.my_location,
              color: AppColors.secondaryColor1,
              size: 20,
            ),
          ),
        );
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          point: position,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      );
    });
  }

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
        final lat = location['lat'];
        final lon = location['lon'];
        setState(() {
          LatLng searchPosition = LatLng(double.parse(lat), double.parse(lon));
          _mapController.move(searchPosition, 14.0);
          _addMarker(searchPosition);
        });
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<void> _showMarkersForCategory(String category) async {
    try {
      final markersData = await HttpService.fetchMapMarkers(category);
      setState(() {
        _markers.clear();
        for (var markerData in markersData) {
          _markers.add(
            Marker(
              point: LatLng(markerData['lat'], markerData['lon']),
              child: Icon(
                Icons.location_pin,
                color: _getMarkerColor(category),
                size: 40,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  Color _getMarkerColor(String category) {
    switch (category) {
      case 'medical':
        return Colors.red;
      case 'parks':
        return Colors.green;
      case 'pensions':
        return Colors.blue;
      case 'restaurants':
        return Colors.orange;
      case 'beauty':
        return Colors.purple;
      case 'hotels':
        return Colors.teal;
      default:
        return Colors.red;
    }
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              AppBar(
                title: Text('All Categories'),
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    _categoryTile('Medical', Icons.local_hospital, Colors.red),
                    _categoryTile('Parks', Icons.park, Colors.green),
                    _categoryTile('Pensions', Icons.home, Colors.blue),
                    _categoryTile('Restaurants', Icons.restaurant, Colors.orange),
                    _categoryTile('Beauty', Icons.spa, Colors.purple),
                    _categoryTile('Hotels', Icons.hotel, Colors.teal),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryTile(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        _showMarkersForCategory(title.toLowerCase());
        Navigator.pop(context);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition,
                    zoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a place',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await _getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _searchPlace(suggestion);
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: FloatingActionButton(
                          onPressed: _updateUserLocation,
                          child: Icon(Icons.my_location, size: 20),
                          backgroundColor: AppColors.primaryColor1.withOpacity(0.7),
                          elevation: 2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 40,
                        width: 40,
                        child: FloatingActionButton(
                          onPressed: _rotateToNorth,
                          child: Icon(Icons.compass_calibration_outlined, size: 20),
                          backgroundColor: AppColors.primaryColor1.withOpacity(0.7),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text('Quick Categories:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.local_hospital, color: Colors.red),
                        onPressed: () => _showMarkersForCategory('medical'),
                        tooltip: 'Medical',
                      ),
                      IconButton(
                        icon: Icon(Icons.park, color: Colors.green),
                        onPressed: () => _showMarkersForCategory('parks'),
                        tooltip: 'Parks',
                      ),
                      IconButton(
                        icon: Icon(Icons.restaurant, color: Colors.orange),
                        onPressed: () => _showMarkersForCategory('restaurants'),
                        tooltip: 'Restaurants',
                      ),
                      IconButton(
                        icon: Icon(Icons.more_horiz, color: Colors.blue),
                        onPressed: () => _showAllCategories(context),
                        tooltip: 'More Categories',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Text('Favorite Places:', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red),
                          title: Text('Favorite Park'),
                          subtitle: Text('Address of Favorite Park'),
                        ),
                        ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red),
                          title: Text('Favorite Pension'),
                          subtitle: Text('Address of Favorite Pension'),
                        ),
                        ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red),
                          title: Text('Favorite Salon'),
                          subtitle: Text('Address of Favorite Salon'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}