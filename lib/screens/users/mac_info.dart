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
  final dealer1 = TextEditingController();
  final dealer2 = TextEditingController();
  final dealer3 = TextEditingController();

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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Correction")),

  //     body: Padding(
  //       padding: const EdgeInsets.all(20),

  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: t1,
  //             decoration: const InputDecoration(labelText: "Value 1"),
  //           ),

  //           TextField(
  //             controller: t2,
  //             decoration: const InputDecoration(labelText: "Value 2"),
  //           ),

  //           TextField(
  //             controller: t3,
  //             decoration: const InputDecoration(labelText: "Value 3"),
  //           ),

  //           const SizedBox(height: 30),

  //           ElevatedButton(onPressed: sendCommand, child: const Text("Write")),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1325),
      appBar: AppBar(
        backgroundColor: Color(0xFF11192A),
        foregroundColor: Color(0xFF0B1325),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 7, 218, 218),
            size: 20,
          ),
        ),
        title: const Text(
          "Correction",
          style: TextStyle(
            color: Color.fromARGB(255, 7, 218, 218),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSection(
                      title: "Channel",
                      children: [
                        _field(t1, "Channel 1"),
                        const SizedBox(height: 15),
                        _field(t2, "Channel 2"),
                        const SizedBox(height: 15),
                        _field(t3, "Channel 3"),
                      ],
                    ),
                  ),

                  const SizedBox(width: 25),

                  Expanded(
                    child: _buildSection(
                      title: "Dealer",
                      children: [
                        _field(dealer1, "Dealer 1"),
                        const SizedBox(height: 15),
                        _field(dealer2, "Dealer 2"),
                        const SizedBox(height: 15),
                        _field(dealer3, "Dealer 3"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 255, 157, 10),
                    ),
                  ),
                  onPressed: sendCommand,
                  child: const Text(
                    "Write",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: Color.fromARGB(255, 77, 100, 153),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF0B1325),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
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
