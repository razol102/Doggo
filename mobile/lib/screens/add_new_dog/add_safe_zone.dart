import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/screens/add_new_dog/configure_collar_screen.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/map/widgets/map_view.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/screens/map/widgets/safe_zone_map_view.dart';
import 'package:mobile/services/http_service.dart';

class AddSafeZoneScreen extends StatefulWidget {
  final int dogId;

  const AddSafeZoneScreen({Key? key, required this.dogId}) : super(key: key);

  static String routeName = "/AddSafeZoneScreen";

  @override
  _AddSafeZoneScreenState createState() => _AddSafeZoneScreenState();
}

class _AddSafeZoneScreenState extends State<AddSafeZoneScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(32.0853, 34.7818); // Default position in Tel Aviv

  LatLng? _selectedPosition;
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

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
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  void _onSearch(LatLng position, String placeName) {
    _mapController.move(position, 14.0);
    _updateSelectedPosition(position);
    _placeNameController.text = placeName;
  }

  void _saveHome() async {
    final placeName = _placeNameController.text;
    final address = _addressController.text;
    final latitude = _selectedPosition?.latitude ?? 0.0;
    final longitude = _selectedPosition?.longitude ?? 0.0;

    if (placeName.isEmpty || address.isEmpty) {
      print('Please fill in all fields');
      return;
    }

    try {
      await HttpService.setFavoritePlace(
        widget.dogId.toString(),
        placeName,
        latitude,
        longitude,
        address,
        "home",
      );
      print('Home added successfully');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfigureCollarScreen(dogId: widget.dogId),
        ),
      );
    } catch (e) {
      print('Failed to add home: $e');
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
                  "Save your dog's home",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Drag the marker to define your dog's home",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
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
                        showClearMarkersButton: false,
                      ),
                      selectedPosition: _selectedPosition,
                      onPositionChanged: _updateSelectedPosition,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _placeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Place Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                RoundGradientButton(
                  title: "Save Home",
                  onPressed: _saveHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
