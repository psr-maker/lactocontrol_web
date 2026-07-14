import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lactosure_control/constant/global/token.dart';
import 'package:lactosure_control/screens/admin/dashboard/settings.dart';
import 'package:lactosure_control/services/serialcom_service.dart';

class Dashboardhome extends StatefulWidget {
  const Dashboardhome({super.key});

  @override
  State<Dashboardhome> createState() => _DashboardhomeState();
}

class _DashboardhomeState extends State<Dashboardhome> {
  String userName = "";
  int? userId;
  String email = "";
  String? connectedPort;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    userName = await TokenCheck.getUserName() ?? "";
    userId = await TokenCheck.getUserId();
    email = await TokenCheck.getEmail() ?? "";
    setState(() {});
  }

  Future<void> showComPortDialog(BuildContext context) async {
    List<String> ports = [];
    String? selectedPort;
    bool loading = true;

    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (loading) {
              SerialComService.getComPorts().then((value) {
                setDialogState(() {
                  ports = value;

                  loading = false;
                });
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Row(
                children: [
                  const Icon(Icons.usb),

                  const SizedBox(width: 10),

                  const Text("Select COM Port"),
                ],
              ),

              content: SizedBox(
                width: 350,

                height: 300,

                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ports.isEmpty
                    ? const Center(child: Text("No COM port found"))
                    : ListView.builder(
                        itemCount: ports.length,

                        itemBuilder: (context, index) {
                          final port = ports[index];

                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.settings_input_component,
                              ),

                              title: Text(port),

                              trailing: selectedPort == port
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : null,

                              onTap: () {
                                setDialogState(() {
                                  selectedPort = port;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: selectedPort == null
                      ? null
                      : () async {
                          final result = await SerialComService.connect(
                            port: selectedPort!,
                            baudRate: 9600,
                          );

                          if (result) {
                            setState(() {
                              connectedPort = selectedPort;

                              isConnected = true;
                            });
                          }

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result
                                    ? "Connected $selectedPort"
                                    : "Connection failed",
                              ),
                            ),
                          );
                        },

                  child: const Text("Connect"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "LactoSure Control",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.link_off : Icons.usb),

            tooltip: isConnected
                ? "Disconnect $connectedPort"
                : "Connect Serial",

            onPressed: () async {
              if (isConnected) {
                final result = await SerialComService.disconnect();

                if (result) {
                  setState(() {
                    isConnected = false;
                    connectedPort = null;
                  });
                }
              } else {
                showComPortDialog(context);
              }
            },
          ),
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Settings()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "User Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Divider(height: 25),

                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  userName.isEmpty ? "-" : userName,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  email.isEmpty ? "-" : email,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
