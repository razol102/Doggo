import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/screens/add_new_dog/configure_collar_screen.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/map/map_view.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/screens/map/safe_zone_map_view.dart';

import '../../services/http_service.dart';

class AddSafeZoneScreen extends StatefulWidget {
  final String name;
  final String? breed;
  final String? gender;
  final String birthdate;
  final String weight;
  final String height;

  const AddSafeZoneScreen({
    Key? key,
    required this.name,
    this.breed,
    this.gender,
    required this.birthdate,
    required this.weight,
    required this.height,
  }) : super(key: key);

  static String routeName = "/AddSafeZoneScreen";

  @override
  _AddSafeZoneScreenState createState() => _AddSafeZoneScreenState();
}

class _AddSafeZoneScreenState extends State<AddSafeZoneScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(32.0853, 34.7818); // Default position in Tel Aviv

  LatLng? _selectedPosition;
  final TextEditingController _nameController = TextEditingController();

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 18.0);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedPosition = _currentPosition;
    _updateUserLocation();
  }

  void _updateSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  void _onSearch(LatLng position, String placeName) {
    _mapController.move(position, 14.0);
    _updateSelectedPosition(position);
    _nameController.text = placeName;
  }

  void _saveSafeZone() async {
    final dogId = await _addNewDogToServer(); // Save all information to the server and get the dogId
    if (dogId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfigureCollarScreen(dogId: dogId),
        ),
      );
    }
  }

  Future<int?> _addNewDogToServer() async {
    try {
      int? currUserId = await PreferencesService.getUserId();
      if (currUserId == null) {
        throw Exception('User ID is null');
      }
      final dogId = await HttpService.addNewDog(
          name: widget.name,
          breed: widget.breed!,
          gender: widget.gender!,
          dateOfBirth: widget.birthdate,
          weight: double.tryParse(widget.weight) ?? 0.0,
          height: double.tryParse(widget.height) ?? 0.0,
          homeLatitude: _selectedPosition?.latitude ?? 0.0,
          homeLongitude: _selectedPosition?.longitude ?? 0.0,
          userId: currUserId
      );
      print('Dog added successfully');
      return dogId; // Assuming the response contains the dogId
    } catch (e) {
      print('Failed to add dog: $e');
      return null;
    }
  }



@override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                const SizedBox(height: 45),
                const Text(
                  "Save your dog's safe zone",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                const Text(
                  "Drag the marker to define your dog's safe zone",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  height: 450,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.lightGrayColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SafeZoneMapView(
                      mapView: MapView(
                        mapController: _mapController,
                        markers: [],
                        currentPosition: _currentPosition,
                        onUpdateLocation: _updateUserLocation,
                        onSearch: _onSearch,
                        onClearMarkers: () {},
                        showClearMarkersButton: false, // Hide the Clear Markers button
                      ),
                      selectedPosition: _selectedPosition,
                      onPositionChanged: _updateSelectedPosition,
                    ),
                  ),
                ),

                SizedBox(height: 25),
                RoundGradientButton(
                  title: "Save Safe Zone",
                  onPressed: _saveSafeZone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
