import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lactosure_control/constant/global/api_url.dart';
import 'package:lactosure_control/services/model/dashboard_model.dart';

class DashboardService {
  static const String url = Api.baseUrl;

  static Future<bool> saveDealerHistory({
    required int userId,
    required String dealer1,
    required String dealer2,
    required String dealer3,
  }) async {
    final response = await http.post(
      Uri.parse("$url/Dashboard/getdealerchange"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "userId": userId,
        "dealer1": dealer1,
        "dealer2": dealer2,
        "dealer3": dealer3,
      }),
    );

    print("STATUS : ${response.statusCode}");

    print("BODY : ${response.body}");

    return response.statusCode == 200;
  }

  static Future<DashboardSummary> getSummary() async {
    final response = await http.get(Uri.parse("$url/Dashboard/summary"));

    return DashboardSummary.fromJson(jsonDecode(response.body));
  }

  static Future<List<DealerHistory>> getHistory() async {
    final response = await http.get(Uri.parse("$url/Dashboard/history"));

    List data = jsonDecode(response.body);

    return data.map((e) => DealerHistory.fromJson(e)).toList();
  }
}
