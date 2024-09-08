import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/services/validation_methods.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/round_textfield.dart';
import 'package:mobile/screens/map/widgets/map_view.dart';
import 'package:geolocator/geolocator.dart';

class PensionVetMapScreen extends StatefulWidget {
  static const String routeName = "/PensionVetMapScreen";
  final String type;
  final bool editMode;

  const PensionVetMapScreen({super.key, this.editMode = false, required this.type});

  @override
  _PensionVetMapScreenState createState() => _PensionVetMapScreenState();
}

class _PensionVetMapScreenState extends State<PensionVetMapScreen> {
  late String _screenType;
  late bool _isEditing;
  String _name = 'Loading...';
  double? _latitude;
  double? _longitude;
  String _phone = '';
  late MapController _mapController;

  String? _nameError;
  String? _locationError;
  String? _phoneError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editMode;
    _screenType = widget.type;
    _mapController = MapController();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final int? dogId = await PreferencesService.getDogId();
      if (dogId == null) {
        _resetData();
        _focusOnUserLocation();
        return;
      }
      Map<String, dynamic>? fetchedInfo;
      switch (_screenType) {
        case "pension":
          fetchedInfo = await HttpService.getPension(dogId);
          print(fetchedInfo);
          break;
        case "vet":
          fetchedInfo = await HttpService.getVet(dogId);
          break;
        default:
          print('Unknown screen type: $_screenType');
          _resetData();
          _focusOnUserLocation();
          return;
      }

      // If data is fetched successfully, update the state
      if (fetchedInfo != null) {
        setState(() {
          _name = fetchedInfo?['${_screenType}_name'];
          _latitude = fetchedInfo?['${_screenType}_latitude'];
          _longitude = fetchedInfo?['${_screenType}_longitude'];
          _phone = fetchedInfo?['${_screenType}_phone'];

          _nameController.text = _name;
          _phoneController.text = _phone;

          // Update markers or focus on user location based on available data
          if (_latitude != null && _longitude != null) {
            _updateMarkers();
          } else {
            _focusOnUserLocation();
          }
        });
      } else {
        // If no data is available, reset and focus on user location
        _resetData();
        _focusOnUserLocation();
      }
    } catch (e) {
      // Handle any errors during the fetch process
      print('Error fetching $_screenType data: $e');
      _resetData();
      _focusOnUserLocation();
    }
  }

  void _resetData() {
    setState(() {
      _name = 'No $_screenType information available';
      _latitude = null;
      _longitude = null;
      _phone = '';
      _markers.clear(); // Clear any markers if present
    });
  }

  Future<void> _focusOnUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        if (!_isEditing) {
          // In view mode, move the map without adding a marker
          _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
        } else {
          // In edit mode, allow updating the marker position
          _latitude = position.latitude;
          _longitude = position.longitude;
          _updateMarkers();
        }
      });
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void _updateMarkers() {
    if (_latitude != null && _longitude != null) {
      _markers = [
        Marker(
          point: LatLng(_latitude!, _longitude!),
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          width: 40,
          height: 40,
        ),
      ];
      _mapController.move(LatLng(_latitude!, _longitude!), 14.0);
    } else {
      _markers = [];
    }
  }

  Future<void> _saveData() async {
    // Validate input fields
    setState(() {
      _nameError = ValidationMethods.validateNotEmpty(_nameController.text, '$_screenType Name');
      _locationError = (_latitude == null || _longitude == null)
          ? 'Location cannot be empty'
          : null;
      _phoneError = ValidationMethods.validatePhoneNumber(_phoneController.text);
    });

    // If there are validation errors, return early
    if (_nameError != null || _locationError != null || _phoneError != null) {
      return;
    }

    try {
      // Fetch the dog ID from preferences
      final int? dogId = await PreferencesService.getDogId();

      if (dogId == null) {
        // Handle case where dog ID is not available
        return;
      }

      // Save the data based on the screen type
      switch (_screenType) {
        case "pension":
          await HttpService.addUpdatePension(
            dogId,
            _nameController.text,
            _phoneController.text,
            _latitude!,
            _longitude!,
          );
          break;
        case "vet":
          await HttpService.addUpdateVet(
            dogId,
            _nameController.text,
            _phoneController.text,
            _latitude!,
            _longitude!,
          );
          break;
        default:
          print('Unknown screen type: $_screenType');
          return;
      }

      // Fetch the updated data and update the state
      await _fetchData();
      setState(() {
        _isEditing = false;
        _nameError = null;
        _locationError = null;
        _phoneError = null;
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$_screenType details updated successfully")),
      );

    } catch (e) {
      // Handle any errors during the save process
      print('Failed to update $_screenType details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update $_screenType details: ${e.toString()}")),
      );
    }
  }

  void _onMapTap(LatLng latLng) {
    if (_isEditing) {
      setState(() {
        _latitude = latLng.latitude;
        _longitude = latLng.longitude;
        _updateMarkers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    LatLng currentPosition = LatLng(_latitude ?? 37.7749, _longitude ?? -122.4194);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                _screenType == "pension" ?
                Image.asset(
                  "assets/images/pension_background.png",
                  width: media.width * 0.4,
                ) :
                Image.asset(
                  "assets/images/vet_background.png",
                  width: media.width * 0.4,
                ) ,
                const SizedBox(height: 5),
                _screenType == "pension" ?
                const Text(
                  "Pension Info",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ) :
                const Text(
                  "Veterinarian Info",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 290,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grayColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MapView(
                    mapController: _mapController,
                    markers: _markers,
                    currentPosition: currentPosition,
                    onUpdateLocation: () {
                      _mapController.move(currentPosition, 14.0);
                    },
                    onSearch: (LatLng location, String placeName) {
                      if (_isEditing) {
                        setState(() {
                          _latitude = location.latitude;
                          _longitude = location.longitude;
                          _updateMarkers();
                        });
                      }
                    },
                    onClearMarkers: () {
                      if (_isEditing) {
                        setState(() {
                          _markers.clear();
                          _latitude = null;
                          _longitude = null;
                        });
                      }
                    },
                    showClearMarkersButton: _isEditing,
                    showSearchBar: _isEditing,
                    onTap: _onMapTap,
                  ),
                ),
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 10),
                RoundTextField(
                  textEditingController: _nameController,
                  hintText: _name.isEmpty ? "Loading..." : _name,
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: !_isEditing,
                  errorText: _nameError,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _phoneController,
                  hintText: _phone.isEmpty ? "Loading..." : _phone,
                  icon: "assets/icons/phone_icon.png",
                  textInputType: TextInputType.phone,
                  readOnly: !_isEditing,
                  errorText: _phoneError,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}