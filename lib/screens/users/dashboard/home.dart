import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/admin/dashboard/settings.dart';
import 'package:lactosure_control/screens/users/mac_info.dart';
import 'package:lactosure_control/services/web_serial_service.dart';

class Dashboardhome extends StatefulWidget {
  const Dashboardhome({super.key});

  @override
  State<Dashboardhome> createState() => _DashboardhomeState();
}

class _DashboardhomeState extends State<Dashboardhome> {
  String? connectedPort;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> showComPortDialog(BuildContext context) async {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFADC6FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(Icons.usb),
              SizedBox(width: 10),
              Text("Connect COM Port"),
            ],
          ),

          content: const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "Click Connect to select your device",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0B1325),
              ),
              onPressed: () async {
                Navigator.pop(context);

                final result = await WebSerialService.connect();

                if (!mounted) return;

                if (result.success) {
                  setState(() {
                    isConnected = true;
                    connectedPort = result.port ?? "Serial Device";
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result.message)));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result.message)));
                }
              },

              child: const Text(
                "Connect",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1325),
      appBar: AppBar(
        backgroundColor: Color(0xFF11192A),
        foregroundColor: Color(0xFF0B1325),
        title: const Text(
          "LactoSure Control",
          style: TextStyle(
            color: Color.fromARGB(255, 7, 218, 218),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isConnected ? Icons.link_off : Icons.usb,
              color: Color.fromARGB(255, 7, 218, 218),
              size: 20,
            ),

            tooltip: isConnected ? "Disconnect" : "Connect Serial",

            onPressed: () async {
              if (isConnected) {
                final result = await WebSerialService.disconnect();

                if (!mounted) return;

                if (result.success) {
                  setState(() {
                    isConnected = false;
                    connectedPort = null;
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result.message)));
                }
              } else {
                showComPortDialog(context);
              }
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
            icon: Icon(
              Icons.settings,
              color: Color.fromARGB(255, 7, 218, 218),
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (!isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Connect machine first")),
                  );

                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Info()),
                );
              },

              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFADC6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 300,
                  height: 200,
                  child: Center(
                    child: Text(
                      "Correction",
                      style: TextStyle(
                        color: Color(0xFF0B1325),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
