import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/preferences_service.dart';

class HttpService {
  static const String baseUrl = "http://34.230.176.208:5000";

  //--------------------------------------auth--------------------------------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/user/login');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) { // user & dog id
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> logout(int userId) async {
    final url = Uri.parse('$baseUrl/api/user/logout?user_id=$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('user $userId logged out!');
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> registerUser(String email, String password, String name, String dateOfBirth, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/user/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'date_of_birth': dateOfBirth,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 201) {
      print('Register completed');
      return jsonDecode(response.body);
    } else {
      print('Register error');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<bool> isLoggedIn(int userId) async {
    final url = Uri.parse('$baseUrl/api/user/connection?user_id=$userId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('User $userId connection status: ${responseData['user_connection']}');
      return responseData['user_connection'] ?? false;
    } else {
      print('Failed to check user connection status. Status code: ${response.statusCode}');
      return false;
    }
  }

  //--------------------------------------complete register--------------------------------------
  static Future<int?> addNewDog({
    required String name,
    required String breed,
    required String gender,
    required String dateOfBirth,
    required double weight,
    required double height,
    required double homeLatitude,
    required double homeLongitude,
    required int userId
  }) async {
    final url = Uri.parse('$baseUrl/api/dog/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'breed': breed,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'weight': weight,
        'height': height,
        'home_latitude': homeLatitude,
        'home_longitude': homeLongitude,
        'user_id': userId
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final dogId = responseData['dog_id'];
      PreferencesService.saveDogId(dogId);
      return dogId;  // Return the dogId
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> configureCollar(int dogId, String collarId) async{
    final url = Uri.parse('$baseUrl/api/collar/add');
    final response = await  http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'collar_id': collarId,
        'dog_id': dogId,
      })
    );

    if (response.statusCode == 200) {
      print('collar $collarId configured to dog $dogId');
    } else {
      print('failed to configure collar $collarId to dog $dogId');
      throw Exception(jsonDecode(response.body)['error']);
    }

  }

  //--------------------------------------user info--------------------------------------
  static Future<Map<String, dynamic>> getUserInfo(int userId) async {
    final url = Uri.parse('$baseUrl/api/user/profile?user_id=$userId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------dog info--------------------------------------
  static Future<Map<String, dynamic>> getDogInfo(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/profile?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------fitness--------------------------------------
  static Future<Map<String, dynamic>> fetchDogActivityStatus(DateTime date) async {
    // query params: '%Y-%m-%d', dogId (int)
    // const url = '$baseUrl/';
    // final response = await http.get(Uri.parse(url));
    //
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to fetch dog activity status');
    // }
    print("Fetching data for $date");
    // Fetch the current steps and total steps from your data source
    int currentSteps = 900; // Replace with actual data fetching
    int totalSteps = 1000; // Replace with actual data fetching
    int calories = 1200;
    double distance = 7;
    return {'currentSteps': currentSteps, 'totalSteps': totalSteps, 'calories': calories, 'distance': distance};
  }

  //--------------------------------------dog friendly places--------------------------------------
  static Future<List<dynamic>> fetchMapMarkers(String category) async {
    final url = Uri.parse('$baseUrl/'); // TODO: change to the real url
    // final response = await http.get(Uri.parse(url));
    //
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to load markers');
    // }

    // Dummy data representing marker locations
    List<dynamic> dummyData = [
      {
        'lat': 32.0853,
        'lon': 34.7818,
        'category': 'medical',
      },
      {
        'lat': 32.04866461125274,
        'lon': 34.76023473261021,
        'category': 'parks',
      },
      {
        'lat': 32.0857,
        'lon': 34.7822,
        'category': 'pensions',
      },
      {
        'lat': 32.0859,
        'lon': 34.7824,
        'category': 'restaurants',
      },
      {
        'lat': 32.0861,
        'lon': 34.7826,
        'category': 'beauty',
      },
      {
        'lat': 32.0863,
        'lon': 34.7828,
        'category': 'hotels',
      },
    ];

    // Filter data based on category
    List<dynamic> filteredData = dummyData.where((marker) => marker['category'] == category).toList();

    return filteredData;
  }

  //--------------------------------------collar data--------------------------------------
  static Future<void> sendStepCountToBackend(String dogId, int stepCount) async {
    final url = Uri.parse('$baseUrl/api/dog/fitness/steps?dog_id=$dogId&steps=$stepCount');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Step count updated successfully');
    } else {
      print('Failed to update step count: ${response.statusCode}');
    }
  }

  static Future<void> sendDistanceToBackend(String dogId, double distance) async {
    final url = Uri.parse('$baseUrl/api/dog/fitness/distance?dog_id=$dogId&distance=$distance');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Distance updated successfully');
    } else {
      print('Failed to update distance: ${response.statusCode}');
    }
  }

  static Future<void> sendBatteryLevelToBackend(String deviceId, int batteryLevel) async {
    final url = Uri.parse('$baseUrl/api/devices/battery');
    final response = await http.put(
      url,
      body: jsonEncode({
        'device_id': deviceId,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'battery_level': '$batteryLevel%',
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Battery level updated successfully');
    } else {
      print('Failed to update battery level: ${response.statusCode}');
    }
  }

  static Future<void> sendWifiConnectionStatusToBackend(String deviceId, bool wifiConnectionStatus) async {
    final url = Uri.parse('$baseUrl/api/devices/wifi_connection_status');
    final response = await http.put(
      url,
      body: jsonEncode({
        'device_id': deviceId,
        'wifi_connection_status': wifiConnectionStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Wifi connection status updated successfully');
    } else {
      print('Failed to update wifi connection status: ${response.statusCode}');
    }
  }

  static Future<void> sendBleConnectionStatusToBackend(String deviceId, bool bleConnectionStatus) async {
    final url = Uri.parse('$baseUrl/api/devices/ble_connection_status');
    final response = await http.put(
      url,
      body: jsonEncode({
        'device_id': deviceId,
        'ble_connection_status': bleConnectionStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Ble connection status updated successfully');
    } else {
      print('Failed to update ble connection status: ${response.statusCode}');
    }
  }

  static Future<String> getCollarId(String dogId) async {
    final url = Uri.parse('$baseUrl/api/collar/get?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['collar_id'];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<int> getBatteryLevel(String collarId) async {
    final url = Uri.parse('$baseUrl/api/devices/battery?collar_id=$collarId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print("status code: ${response.statusCode}");
    if(response.statusCode == 200) {
      return jsonDecode(response.body)['battery_level'];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------test--------------------------------------
  static Future<Map<String, dynamic>> getRoot() async {
    final url = Uri.parse('$baseUrl/');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

}
