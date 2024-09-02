import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/screens/add_new_dog/configure_collar_screen.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/map/widgets/map_view.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/services/http_service.dart';

class SetFavoritePlace extends StatefulWidget {
  final int dogId;
  final String placeType;
  final bool inCompleteRegister;
  final bool editMode;

  const SetFavoritePlace({
    Key? key,
    required this.dogId,
    required this.placeType,
    this.inCompleteRegister = false,
    this.editMode = true
  }) : super(key: key);

  static String routeName = "/SetFavoritePlaceScreen";

  @override
  _SetFavoritePlaceState createState() => _SetFavoritePlaceState();
}

class _SetFavoritePlaceState extends State<SetFavoritePlace> {
  late bool _isEditing;
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(32.0853, 34.7818); // Default position in Tel Aviv

  LatLng? _selectedPosition;
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // final TextEditingController _latitudeController = TextEditingController();
  // final TextEditingController _longitudeController = TextEditingController();

  List<Marker> _markers = [];

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _selectedPosition ??= _currentPosition;
        _mapController.move(_selectedPosition!, 18.0);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchFavoritePlace() async {
    try {
      final place = await HttpService.getFavoritePlaceByType(widget.dogId, widget.placeType);

      if (place != null) {
        setState(() {
          _placeNameController.text = place['place_name'] ?? '';
          _addressController.text = place['address'] ?? '';
          _selectedPosition = LatLng(
            place['place_latitude'] ?? _currentPosition.latitude,
            place['place_longitude'] ?? _currentPosition.longitude,
          );

          // Move map to the selected position immediately
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(_selectedPosition!, 18.0);
            _updateMarkers();  // Add marker after moving the map
          });
        });
      }
    } catch (e) {
      print('Failed to fetch favorite place: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editMode;
    _fetchFavoritePlace(); // Fetch and populate the favorite place data
    _updateUserLocation();
  }

  void _updateSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  void _onSearch(LatLng position, String placeName) {
    _mapController.move(position, 18.0);
    _updateSelectedPosition(position);
    _placeNameController.text = placeName;
  }

  void _savePlace() async {
    final placeName = _placeNameController.text.isEmpty ? "no name" : _placeNameController.text;
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
        widget.placeType,
      );
      print('Place added successfully');
      if (widget.inCompleteRegister == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfigureCollarScreen(dogId: widget.dogId),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Failed to add place: $e');
    }
  }

  void _updateMarkers() {
      _markers = [
        Marker(
          point: _selectedPosition ?? _currentPosition,
          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          width: 40,
          height: 40,
        ),
      ];
      _mapController.move(_selectedPosition ?? _currentPosition, 18.0);
  }

  void _onMapTap(LatLng latLng) {
    if (_isEditing) {
      setState(() {
        _selectedPosition = latLng;
        _updateMarkers();
      });
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 45),
                Text(
                  "Save your dog's ${widget.placeType}",
                  style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Tap the map to define your dog's ${widget.placeType}",
                  style: const TextStyle(
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
                    child: MapView(
                      mapController: _mapController,
                      markers: _markers,
                      currentPosition: _currentPosition,
                      onUpdateLocation: () {
                        _mapController.move(_currentPosition, 14.0);
                      },
                      onSearch: _onSearch,
                      onClearMarkers: () {
                        if (_isEditing) {
                          setState(() {
                            _markers.clear();
                          });
                        }
                      },
                      showClearMarkersButton: _isEditing,
                      showSearchBar: _isEditing,
                      onTap: _onMapTap,
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
                  title: "Save",
                  onPressed: _savePlace,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
