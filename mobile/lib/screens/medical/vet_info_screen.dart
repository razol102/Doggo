// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mobile/services/http_service.dart';
// import 'package:mobile/services/preferences_service.dart';
// import 'package:mobile/utils/app_colors.dart';
// import 'package:mobile/common_widgets/round_textfield.dart';
// import 'package:mobile/screens/map/widgets/map_view.dart';
// import 'package:geolocator/geolocator.dart';
//
// class VetInfoScreen extends StatefulWidget {
//   static const String routeName = "/VetInfoScreen";
//
//   final bool editMode;
//
//   const VetInfoScreen({super.key, this.editMode = false});
//
//   @override
//   _VetInfoScreenState createState() => _VetInfoScreenState();
// }
//
// class _VetInfoScreenState extends State<VetInfoScreen> {
//   late bool _isEditing;
//   String _pensionName = 'Loading...';
//   double? _pensionLatitude;
//   double? _pensionLongitude;
//   late MapController _mapController;
//
//   String? _nameError;
//   String? _locationError;
//
//   final TextEditingController _nameController = TextEditingController();
//
//   List<Marker> _markers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _isEditing = widget.editMode;
//     _mapController = MapController();
//     _fetchPensionData();
//   }
//   Future<void> _fetchPensionData() async {
//     try {
//       final int? dogId = await PreferencesService.getDogId();
//       if (dogId != null) {
//         final pensionInfo = await HttpService.getPension(dogId);
//         if (pensionInfo != null) {
//           setState(() {
//             _pensionName = pensionInfo['pension_name'];
//             _pensionLatitude = pensionInfo['pension_latitude'];
//             _pensionLongitude = pensionInfo['pension_longitude'];
//
//             _nameController.text = _pensionName;
//
//             // Update markers if valid location data is available
//             if (_pensionLatitude != null && _pensionLongitude != null) {
//               _updateMarkers();
//             } else {
//               // Focus on the user's location if pension location is not available
//               _focusOnUserLocation();
//             }
//           });
//         } else {
//           // No pension info, focus on user location
//           _resetPensionData();
//           _focusOnUserLocation();
//         }
//       }
//     } catch (e) {
//       print('Error fetching pension data: $e');
//       _resetPensionData();
//       _focusOnUserLocation();
//     }
//   }
//
//   void _resetPensionData() {
//     setState(() {
//       _pensionName = 'No pension information available';
//       _pensionLatitude = null;
//       _pensionLongitude = null;
//       _markers.clear(); // Clear any markers if present
//     });
//   }
//
//   Future<void> _focusOnUserLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       setState(() {
//         if (!_isEditing) {
//           // In view mode, move the map without adding a marker
//           _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
//         } else {
//           // In edit mode, allow updating the marker position
//           _pensionLatitude = position.latitude;
//           _pensionLongitude = position.longitude;
//           _updateMarkers();
//         }
//       });
//     } catch (e) {
//       print('Error getting user location: $e');
//     }
//   }
//
//
//   void _updateMarkers() {
//     if (_pensionLatitude != null && _pensionLongitude != null) {
//       _markers = [
//         Marker(
//           point: LatLng(_pensionLatitude!, _pensionLongitude!),
//           child: Icon(Icons.location_pin, color: Colors.red, size: 40),
//           width: 40,
//           height: 40,
//         ),
//       ];
//       _mapController.move(LatLng(_pensionLatitude!, _pensionLongitude!), 14.0);
//     } else {
//       _markers = [];
//     }
//   }
//
//   Future<void> _savePensionData() async {
//     setState(() {
//       _nameError = _validateNotEmpty(_nameController.text, 'Pension Name');
//       if (_pensionLatitude == null || _pensionLongitude == null) {
//         _locationError = 'Location cannot be empty';
//       } else {
//         _locationError = null;
//       }
//
//     });
//
//     if (_nameError != null || _locationError != null) {
//       return;
//     }
//
//     try {
//       final int? dogId = await PreferencesService.getDogId();
//       if (dogId != null) {
//         await HttpService.addUpdatePension(
//           dogId,
//           _nameController.text,
//           _pensionLatitude!,
//           _pensionLongitude!,
//         );
//         await _fetchPensionData();
//         setState(() {
//           _isEditing = false;
//           _nameError = null;
//           _locationError = null;
//
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Pension details updated successfully")),
//         );
//       }
//     } catch (e) {
//       print('Failed to update pension details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update pension details: ${e.toString()}")),
//       );
//     }
//   }
//
//   String? _validateNotEmpty(String value, String fieldName) {
//     if (value.isEmpty) {
//       return '$fieldName cannot be empty';
//     }
//     return null;
//   }
//
//   void _onMapTap(LatLng latLng) {
//     if (_isEditing) {
//       setState(() {
//         _pensionLatitude = latLng.latitude;
//         _pensionLongitude = latLng.longitude;
//         _updateMarkers();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context).size;
//     LatLng currentPosition = LatLng(_pensionLatitude ?? 37.7749, _pensionLongitude ?? -122.4194);
//
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         backgroundColor: AppColors.whiteColor,
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               if (_isEditing) {
//                 _savePensionData();
//               } else {
//                 setState(() {
//                   _isEditing = true;
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Column(
//               children: [
//                 Image.asset(
//                   "assets/images/pension_background.png",
//                   width: media.width * 0.5,
//                 ),
//                 const SizedBox(height: 15),
//                 const Text(
//                   "Pension Info",
//                   style: TextStyle(
//                     color: AppColors.blackColor,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Container(
//                   height: 290,
//                   margin: const EdgeInsets.symmetric(vertical: 15),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.grayColor),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: MapView(
//                     mapController: _mapController,
//                     markers: _markers,
//                     currentPosition: currentPosition,
//                     onUpdateLocation: () {
//                       _mapController.move(currentPosition, 14.0);
//                     },
//                     onSearch: (LatLng location, String placeName) {
//                       if (_isEditing) {
//                         setState(() {
//                           _pensionLatitude = location.latitude;
//                           _pensionLongitude = location.longitude;
//                           _updateMarkers();
//                         });
//                       }
//                     },
//                     onClearMarkers: () {
//                       if (_isEditing) {
//                         setState(() {
//                           _markers.clear();
//                           _pensionLatitude = null;
//                           _pensionLongitude = null;
//                         });
//                       }
//                     },
//                     showClearMarkersButton: _isEditing,
//                     showSearchBar: _isEditing,
//                     onTap: _onMapTap,
//                   ),
//                 ),
//                 if (_locationError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 5),
//                     child: Text(
//                       _locationError!,
//                       style: const TextStyle(color: Colors.red, fontSize: 12),
//                     ),
//                   ),
//                 const SizedBox(height: 15),
//                 RoundTextField(
//                   textEditingController: _nameController,
//                   hintText: _pensionName.isEmpty ? "Loading..." : _pensionName,
//                   icon: "assets/icons/name_icon.png",
//                   textInputType: TextInputType.text,
//                   readOnly: !_isEditing,
//                   errorText: _nameError,
//                 ),
//                 const SizedBox(height: 15),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }