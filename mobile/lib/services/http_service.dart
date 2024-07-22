import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = "https://doggo-api-test.redwave-5a54044b.australiaeast.azurecontainerapps.io/api";

  static Future<Map<String, dynamic>> login(String username, String password) async {
    const url = '$baseUrl/auth/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if(response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
}
