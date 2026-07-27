import 'package:flutter/material.dart';
import 'package:lactosure_control/constant/global/loadingflw.dart';
import 'package:lactosure_control/constant/global/token.dart';
import 'package:lactosure_control/screens/admin/dashboard/settings.dart';
import 'package:lactosure_control/screens/users/mac_info.dart';
import 'package:lactosure_control/services/dashboard_service.dart';
import 'package:lactosure_control/services/model/dashboard_model.dart';
import 'package:lactosure_control/services/web_serial_service.dart';

class Dashboardhome extends StatefulWidget {
  const Dashboardhome({super.key});

  @override
  State<Dashboardhome> createState() => _DashboardhomeState();
}

class _DashboardhomeState extends State<Dashboardhome> {
  String? connectedPort;
  bool isConnected = false;
  String userName = "";
  int? userId;
  String email = "";
  final TextEditingController dateFilter = TextEditingController();
  List<DealerHistory> historyList = [];
  bool loading = false;

  List<DealerHistory> filteredHistory = [];
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    dateFilter.dispose();
    super.dispose();
  }

  Future<void> showComPortDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFADC6FF),
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
                backgroundColor: const Color(0xFF0B1325),
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
                }

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result.message)));
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

  Future<void> loadUser() async {
    final name = await TokenCheck.getUserName() ?? "";
    final id = await TokenCheck.getUserId();
    final mail = await TokenCheck.getEmail() ?? "";

    if (!mounted) return;

    setState(() {
      userName = name;
      userId = id;
      email = mail;
    });

    if (userId != null) {
      await loadHistory();
    }
  }

  Future<void> loadHistory() async {
    final data = await DashboardService().getDealerHistory(userId!);

    historyList = data.map((e) => DealerHistory.fromJson(e)).toList();

    filteredHistory = List.from(historyList);

    setState(() {});
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateFilter.text =
          "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";

      applyDateFilter();
    }
  }

  void applyDateFilter() {
    if (dateFilter.text.isEmpty) {
      filteredHistory = List.from(historyList);
    } else {
      filteredHistory = historyList.where((item) {
        return item.date == dateFilter.text;
      }).toList();
    }

    setState(() {});
  }

  void clearFilter() {
    dateFilter.clear();

    filteredHistory = List.from(historyList);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1325),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11192A),
        title: const Text(
          " LactoSure Dashboard",
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
              color: const Color.fromARGB(255, 7, 218, 218),
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
            icon: const Icon(
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
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF2E3B55),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFF3B82F6),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name : ${userName.isEmpty ? "-" : userName}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Email : ${email.isEmpty ? "-" : email}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF2E3B55),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.memory,
                                  color: Color(0xFF60A5FA),
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Connected Machine",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),
                            Row(
                              children: [
                                const Text(
                                  "Status : ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  isConnected
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: isConnected
                                      ? Colors.green
                                      : Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isConnected ? "Connected" : "Not Connected",
                                  style: TextStyle(
                                    color: isConnected
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  "Port : ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  connectedPort ?? "-",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
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
                SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isConnected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Connect machine first"),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Info()),
                      );
                    },
                    child: Container(
                      // width: 300,
                      height: MediaQuery.of(context).size.height*0.35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF151F36),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF273554)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Color(0xFF4FD1C5),
                            child: Icon(
                              Icons.settings,
                              color: Color(0xFF0B1325),
                              size: 34,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Configure your machine",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Audit Trail",
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 154, 255),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: selectDate,
                          icon: const Icon(
                            Icons.filter_alt,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            clearFilter();
                            loadHistory();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: loading
                              ? const Padding(
                                  padding: EdgeInsets.all(30),
                                  child: Center(child: RotatingFlower()),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.white10,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text("Name")),
                                      DataColumn(label: Text("Date")),
                                      DataColumn(label: Text("Dealer 1")),
                                      DataColumn(label: Text("Dealer 2")),
                                      DataColumn(label: Text("Dealer 3")),
                                    ],
                                    rows: filteredHistory.map((item) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(item.name)),
                                          DataCell(Text(item.date)),
                                          DataCell(Text(item.dealer1)),
                                          DataCell(Text(item.dealer2)),
                                          DataCell(Text(item.dealer3)),
                                        ],
                                      );
                                    }).toList(),

                                    headingTextStyle: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    dataTextStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
