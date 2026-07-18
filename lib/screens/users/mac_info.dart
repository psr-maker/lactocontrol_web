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
    String value1 = fixLength(dealer1.text, 32);
    String value2 = fixLength(dealer2.text, 20);
    String value3 = fixLength(dealer3.text, 29);

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

  Future<void> writeField({
    required TextEditingController controller,
    required int address,
    required int length,
  }) async {
    String text = fixLength(controller.text, length);

    List<int> command = [
      0x40,
      0x0C,
      0xFA,
      0xA0,
      (address >> 8) & 0xFF,
      address & 0xFF,
      ...text.codeUnits,
    ];

    int lrc = 0;
    for (final b in command) {
      lrc ^= b;
    }

    command.add(lrc);

    await sendMachineCommand(command);
  }

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
                        _field(t1, "Channel 1", () async {
                          await writeField(
                            controller: t1,
                            address: 0x003C,
                            length: 7,
                          );
                        }),
                        _field(t2, "Channel 2", () async {
                          await writeField(
                            controller: t2,
                            address: 0x0082,
                            length: 7,
                          );
                        }),
                        _field(t3, "Channel 3", () async {
                          await writeField(
                            controller: t3,
                            address: 0x00C8,
                            length: 7,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(width: 25),

                  Expanded(
                    child: _buildSection(
                      title: "Dealer",
                      children: [
                        TextField(
                          controller: dealer1,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Dealer 1"),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: dealer2,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Dealer 2"),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: dealer3,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Dealer 3"),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 50,
                            width: 90,
                            child: ElevatedButton(
                              onPressed: sendCommand,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF07DADA),
                                foregroundColor: const Color(0xFF0B1325),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Write",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF07DADA).withOpacity(.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF07DADA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    VoidCallback onWrite,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF07DADA),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onWrite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07DADA),
                foregroundColor: const Color(0xFF0B1325),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              label: const Text(
                "Write",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFF1E293B),

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF07DADA), width: 2),
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
