import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/screens/map/safe_zone_map_view.dart';
import 'package:mobile/screens/map/map_view.dart';

class EditSafeZoneScreen extends StatefulWidget {
  static String routeName = "/EditSafeZoneScreen";

  const EditSafeZoneScreen({Key? key}) : super(key: key);

  @override
  _EditSafeZoneScreenState createState() => _EditSafeZoneScreenState();
}

class _EditSafeZoneScreenState extends State<EditSafeZoneScreen> {
  late Future<Map<String, dynamic>> _dogInfoFuture;
  LatLng? _homePosition; // Make this nullable
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dogInfoFuture = _fetchDogIdAndInfo();
  }

  Future<Map<String, dynamic>> _fetchDogIdAndInfo() async {
    try {
      final dogId = await PreferencesService.getDogId();
      if (dogId == null) {
        throw Exception('Dog ID is null');
      }
      final info = await HttpService.getDogInfo(dogId);
      setState(() {
        _homePosition = LatLng(info['home_latitude'], info['home_longitude']);
        _selectedPosition = _homePosition;
        if (_homePosition != null) {
          _mapController.move(_homePosition!, 14.0);
        }
        _nameController.text = info['name'];
      });
      return info;
    } catch (e) {
      throw Exception('Failed to load dog info: $e');
    }
  }

  void _updateSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  void _saveSafeZone() async {
    try {
      final dogId = await PreferencesService.getDogId();
      if (dogId == null) {
        throw Exception('Dog ID is null');
      }
      // await HttpService.updateDogSafeZone(
      //   dogId: dogId,
      //   homeLatitude: _selectedPosition?.latitude ?? 0.0,
      //   homeLongitude: _selectedPosition?.longitude ?? 0.0,
      // );
      // Navigator.pop(context); // Navigate back to previous screen or show a success message
    } catch (e) {
      print('Failed to update safe zone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text('Edit Safe Zone'),
        backgroundColor: AppColors.primaryColor1,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dogInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
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
                              currentPosition: _homePosition!,
                              onUpdateLocation: () {}, // You might want to handle location updates here
                              onSearch: (position, placeName) {},
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
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
