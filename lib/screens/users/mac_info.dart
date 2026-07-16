import 'package:flutter/material.dart';
import 'package:lactosure_control/services/web_serial_service.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final TextEditingController t1 = TextEditingController();
  final TextEditingController t2 = TextEditingController();
  final TextEditingController t3 = TextEditingController();

  String fixLength(String text, int length) {
    if (text.length > length) {
      return text.substring(0, length);
    }

    return text.padRight(length, ' ');
  }

  Future<void> sendCommand() async {
    String value1 = fixLength(t1.text, 32);
    String value2 = fixLength(t2.text, 20);
    String value3 = fixLength(t3.text, 29);

    String fullText = value1 + value2 + value3;

    List<int> data = fullText.codeUnits;

    // WRITE COMMAND
    List<int> writeCommand = [0x40, 0x56, 0xFA, 0xA0, 0x03, 0x0C, ...data];

    // LRC
    int lrc = 0;

    for (final byte in writeCommand) {
      lrc ^= byte;
    }

    writeCommand.add(lrc);

    debugPrint("========== WRITE COMMAND ==========");

    debugPrint(
      writeCommand
          .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(" "),
    );

    await sendMachineCommand(writeCommand);
  }

  Future<void> sendMachineCommand(List<int> writeCommand) async {
    try {
      // ============== LOGIN ==============

      debugPrint("========== LOGIN ==========");

      final login = hex("40 04 06 00 00 42");

      final loginResponse = await WebSerialService.write(login);

      debugPrint("LOGIN : ${loginResponse.message}");

      await Future.delayed(const Duration(seconds: 3));

      // ============== WRITE ==============

      debugPrint("========== WRITE ==========");

      final writeResponse = await WebSerialService.write(writeCommand);

      if (!writeResponse.success) {
        debugPrint("WRITE FAILED : ${writeResponse.message}");

        return;
      }

      debugPrint("WRITE SUCCESS : ${writeResponse.message}");

      await Future.delayed(const Duration(seconds: 3));

      // ============== LOGOUT ==============

      debugPrint("========== LOGOUT ==========");

      final logout = hex("40 04 D1 00 00 95");

      final logoutResponse = await WebSerialService.write(logout);

      debugPrint("LOGOUT : ${logoutResponse.message}");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Machine Write Completed")));
    } catch (e) {
      debugPrint("MACHINE ERROR : $e");
    }
  }

  List<int> hex(String value) {
    return value.split(' ').map((e) => int.parse(e, radix: 16)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Correction")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: t1,
              decoration: const InputDecoration(labelText: "Value 1"),
            ),

            TextField(
              controller: t2,
              decoration: const InputDecoration(labelText: "Value 2"),
            ),

            TextField(
              controller: t3,
              decoration: const InputDecoration(labelText: "Value 3"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: sendCommand, child: const Text("Write")),
          ],
        ),
      ),
    );
  }
}

class SerialResponse {
  final bool success;
  final String message;
  final String? port;

  SerialResponse({required this.success, required this.message, this.port});

  factory SerialResponse.fromMap(Map<String, dynamic> map) {
    return SerialResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      port: map['port'],
    );
  }
}
