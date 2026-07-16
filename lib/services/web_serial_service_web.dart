@JS()
library web_serial_service_web;

import 'dart:js_interop';

import 'package:lactosure_control/screens/users/mac_info.dart';

@JS('connectSerial')
external JSPromise<JSAny?> connectSerial();

@JS('writeSerial')
external JSPromise<JSAny?> writeSerial(JSArray<JSNumber> data);

@JS('disconnectSerial')
external JSPromise<JSAny?> disconnectSerial();
@JS('readSerial')
external JSPromise<JSAny?> readSerial();

class WebSerialService {
  static Future<SerialResponse> connect() async {
    final js = await connectSerial().toDart;

    final map = Map<String, dynamic>.from((js as JSObject).dartify() as Map);

    final response = SerialResponse.fromMap(map);

    print("========== SERIAL CONNECT ==========");
    print("Status  : ${response.success}");
    print("Port    : ${response.port}");
    print("Message : ${response.message}");

    return response;
  }

  static Future<SerialResponse> write(List<int> data) async {
    print("========== SERIAL WRITE ==========");

    print(
      data
          .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(" "),
    );

    print("Total Bytes : ${data.length}");

    final jsArray = data.map((e) => e.toJS).toList().toJS;

    final js = await writeSerial(jsArray).toDart;

    final map = Map<String, dynamic>.from((js as JSObject).dartify() as Map);

    final response = SerialResponse.fromMap(map);

    if (response.success) {
      print("🍭🍭🍭${response.message}");
    } else {
      print("❌ ${response.message}");
    }

    return response;
  }

  static Future<SerialResponse> disconnect() async {
    final js = await disconnectSerial().toDart;

    final map = Map<String, dynamic>.from((js as JSObject).dartify() as Map);

    final response = SerialResponse.fromMap(map);

    print("========== SERIAL DISCONNECT ==========");
    print("Status  : ${response.success}");
    print("Message : ${response.message}");

    return response;
  }
  static Future<Map<String,dynamic>> read() async {

  final js = await readSerial().toDart;

  final map = Map<String,dynamic>.from(
    (js as JSObject).dartify() as Map
  );

  return map;
}
}
