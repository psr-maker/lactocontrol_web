import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lactosure_control/constant/global/api_url.dart';

class SerialComService {
  static const String baseUrl = Api.baseUrl;

  static Future<List<String>> getComPorts() async {
    final response = await http.get(Uri.parse("$baseUrl/serialcom/ports"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception("Unable to load COM ports");
    }
  }

  // Connect COM port
  static Future<bool> connect({
    required String port,
    int baudRate = 9600,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/serialcom/connect"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"portName": port, "baudRate": baudRate}),
    );

    return response.statusCode == 200;
  }

  // Disconnect COM port
  static Future<bool> disconnect() async {
    final response = await http.post(
      Uri.parse("$baseUrl/serialcom/disconnect"),
    );

    return response.statusCode == 200;
  }

  // Check connection status
  static Future<bool> status() async {
    final response = await http.get(Uri.parse("$baseUrl/serialcom/status"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["connected"] ?? false;
    }

    return false;
  }
}
