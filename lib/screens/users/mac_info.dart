import 'package:flutter/material.dart';
import 'package:lactosure_control/constant/global/loadingflw.dart';
import 'package:lactosure_control/constant/global/token.dart';
import 'package:lactosure_control/services/dashboard_service.dart';
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
  bool _channel1Loading = false;
  bool _channel2Loading = false;
  bool _channel3Loading = false;
  bool _dealerLoading = false;

  String fixLength(String text, int length) {
    // Add one leading space
    // text = "$text";

    if (text.length > length) {
      return text.substring(0, length);
    }

    return text.padRight(length, ' ');
  }

  Future<void> sendCommand() async {
    if (_dealerLoading) return;

    setState(() {
      _dealerLoading = true;
    });

    try {
      String value1 = fixLength(dealer1.text, 32);
      String value2 = fixLength(dealer2.text, 20);
      String value3 = fixLength(dealer3.text, 29);

      String fullText = value1 + value2 + value3;

      List<int> data = fullText.codeUnits;

      List<int> writeCommand = [0x40, 0x56, 0xFA, 0xA0, 0x03, 0x0C, ...data];

      int lrc = 0;

      for (final byte in writeCommand) {
        lrc ^= byte;
      }

      writeCommand.add(lrc);

      // MACHINE WRITE
      bool success = await sendMachineCommand(writeCommand);

      // AFTER SUCCESS SAVE HISTORY
      if (success) {
        int? userId = await TokenCheck.getUserId();

        if (userId != null) {
          bool saved = await DashboardService.saveDealerHistory(
            userId: userId,

            dealer1: dealer1.text,

            dealer2: dealer2.text,

            dealer3: dealer3.text,
          );

          if (saved) {
            debugPrint("Dealer history saved");
          } else {
            debugPrint("Dealer history save failed");
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _dealerLoading = false;
        });
      }
    }
  }

  Future<bool> sendMachineCommand(List<int> writeCommand) async {
    try {
      debugPrint("========== LOGIN ==========");

      final login = hex("40 04 06 00 00 42");

      final loginResponse = await WebSerialService.write(login);

      if (!loginResponse.success) {
        return false;
      }

      await Future.delayed(const Duration(seconds: 3));

      debugPrint("========== WRITE ==========");

      final writeResponse = await WebSerialService.write(writeCommand);

      if (!writeResponse.success) {
        debugPrint("WRITE FAILED : ${writeResponse.message}");

        return false;
      }

      debugPrint("WRITE SUCCESS : ${writeResponse.message}");

      await Future.delayed(const Duration(seconds: 3));

      debugPrint("========== LOGOUT ==========");

      final logout = hex("40 04 D1 00 00 95");

      final logoutResponse = await WebSerialService.write(logout);

      debugPrint("LOGOUT : ${logoutResponse.message}");

      if (!logoutResponse.success) {
        return false;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Machine Write Completed")),
        );
      }

      return true;
    } catch (e) {
      debugPrint("MACHINE ERROR : $e");

      return false;
    }
  }

  List<int> hex(String value) {
    return value.split(' ').map((e) => int.parse(e, radix: 16)).toList();
  }

  Future<void> writeField({
    required TextEditingController controller,
    required int address,
    required int length,
    required int button,
  }) async {
    setState(() {
      if (button == 1) _channel1Loading = true;
      if (button == 2) _channel2Loading = true;
      if (button == 3) _channel3Loading = true;
    });

    try {
      String text = fixLength(controller.text, length);

      List<int> command = [
        0x40,
        0x0E,
        0xFA,
        0xA0,
        (address >> 8) & 0xFF,
        address & 0xFF,
        0x08,
        ...text.codeUnits,
      ];

      int lrc = 0;
      for (final b in command) {
        lrc ^= b;
      }

      command.add(lrc);
      await sendMachineCommand(command);
    } finally {
      if (mounted) {
        setState(() {
          if (button == 1) _channel1Loading = false;
          if (button == 2) _channel2Loading = false;
          if (button == 3) _channel3Loading = false;
        });
      }
    }
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
                        _field(t1, "Channel 1", _channel1Loading, () async {
                          await writeField(
                            controller: t1,
                            address: 0x003C,
                            length: 8,
                            button: 1,
                          );
                        }),
                        _field(t2, "Channel 2", _channel2Loading, () async {
                          await writeField(
                            controller: t2,
                            address: 0x0082,
                            length: 8,
                            button: 2,
                          );
                        }),
                        _field(t3, "Channel 3", _channel3Loading, () async {
                          await writeField(
                            controller: t3,
                            address: 0x00C8,
                            length: 8,
                            button: 3,
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
                              onPressed: _dealerLoading ? null : sendCommand,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF07DADA),
                                foregroundColor: const Color(0xFF0B1325),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _dealerLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: RotatingFlower(),
                                    )
                                  : const Text(
                                      "Write",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
    bool loading,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07DADA),
                foregroundColor: const Color(0xFF0B1325),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: loading ? null : onWrite,
              label: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: RotatingFlower(),
                    )
                  : const Text("Write"),
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
