import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/map/widgets/map_view.dart';

class SafeZoneMapView extends StatelessWidget {
  final MapView mapView;
  final LatLng? selectedPosition;
  final Function(LatLng) onPositionChanged;

  const SafeZoneMapView({
    Key? key,
    required this.mapView,
    required this.selectedPosition,
    required this.onPositionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mapView,
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final localPosition = renderBox.globalToLocal(details.globalPosition);
              final latlng = mapView.mapController.pointToLatLng(
                CustomPoint(localPosition.dx, localPosition.dy),
              );
              if (latlng != null) {
                onPositionChanged(latlng);
              }
            },
          ),
        ),
        if (selectedPosition != null)
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.location_on,
                color: AppColors.primaryColor1,
                size: 50,
              ),
            ),
          ),
      ],
    );
  }
}
