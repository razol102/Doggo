import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/utils/app_colors.dart';
import 'search_bar.dart';

class MapView extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final LatLng currentPosition;
  final VoidCallback onUpdateLocation;
  final Function(LatLng, String) onSearch;
  final VoidCallback onClearMarkers; // Add this parameter

  const MapView({
    Key? key,
    required this.mapController,
    required this.markers,
    required this.currentPosition,
    required this.onUpdateLocation,
    required this.onSearch,
    required this.onClearMarkers, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: currentPosition,
            zoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          top: 40,
          left: 10,
          right: 10,
          child: PlaceSearchBar(onSearch: onSearch),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'updateLocation',
                onPressed: onUpdateLocation,
                child: Icon(Icons.my_location, size: 20,),
                backgroundColor: AppColors.primaryColor1.withOpacity(0.8),
                mini: true,
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'rotateNorth',
                onPressed: () => mapController.rotate(0),
                backgroundColor: AppColors.primaryColor1.withOpacity(0.8),
                mini: true,
                child: Image.asset(
                  'assets/icons/compass.png',
                  height: 20,
                  width: 20,
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'clearMarkers',
                onPressed: onClearMarkers,
                backgroundColor: AppColors.primaryColor1.withOpacity(0.8),
                mini: true, // Set the callback here
                child: Image.asset(
                  'assets/icons/remove_location.png',
                  height: 20,
                  width: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
