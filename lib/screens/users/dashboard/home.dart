import 'dart:async';
import 'package:flutter/material.dart';
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
            child: Center(child: Text("Click Connect to select your device")),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
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

              child: const Text("Connect"),
            ),
          ],
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

              child: Container(child: Text("Correction")),
            ),
          ],
        ),
      ),
    );
  }
}
