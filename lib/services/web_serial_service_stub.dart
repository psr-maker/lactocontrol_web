import 'package:lactosure_control/screens/users/mac_info.dart';

class WebSerialService {
  static Future<SerialResponse> connect() async {
    throw UnsupportedError("Web Serial is only supported on Flutter Web");
  }

  static Future<SerialResponse> write(List<int> data) async {
    throw UnsupportedError("Web Serial is only supported on Flutter Web");
  }

  static Future<SerialResponse> disconnect() async {
    throw UnsupportedError("Web Serial is only supported on Flutter Web");
  }

  static Future<SerialResponse> read() async {
    throw UnsupportedError("Web Serial is only supported on Flutter Web");
  }
}
