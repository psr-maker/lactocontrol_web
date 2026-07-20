import 'package:flutter/material.dart';
import 'package:lactosure_control/services/dashboard_service.dart';
import 'package:lactosure_control/services/model/dashboard_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color background = const Color(0xFF0B1325);
  final Color cardColor = const Color(0xFF17233A);
  final Color borderColor = Colors.white12;

  DashboardSummary? summary;

  List<DealerHistory> history = [];
  final TextEditingController nameFilter = TextEditingController();
  final TextEditingController dateFilter = TextEditingController();

  List<DealerHistory> filteredHistory = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final s = await DashboardService.getSummary();

      final h = await DashboardService.getHistory();

      setState(() {
        summary = s;

        history = h;

        filteredHistory = h;

        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void applyFilter() {
    setState(() {
      filteredHistory = history.where((item) {
        bool nameMatch = true;
        bool dateMatch = true;

        if (nameFilter.text.isNotEmpty) {
          nameMatch = item.name.toLowerCase().contains(
            nameFilter.text.toLowerCase(),
          );
        }

        if (dateFilter.text.isNotEmpty) {
          dateMatch = item.date == dateFilter.text;
        }

        return nameMatch && dateMatch;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          backgroundColor: Color(0xFFADC6FF),
          title: const Text("Filter"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) {
                    return history.map((e) => e.name).toSet();
                  }

                  return history
                      .map((e) => e.name)
                      .toSet()
                      .where(
                        (name) => name.toLowerCase().contains(
                          value.text.toLowerCase(),
                        ),
                      );
                },

                onSelected: (String value) {
                  nameFilter.text = value;
                },

                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,

                        focusNode: focusNode,

                        decoration: const InputDecoration(
                          labelText: "Name",

                          border: OutlineInputBorder(),
                        ),

                        onChanged: (value) {
                          nameFilter.text = value;
                        },
                      );
                    },
              ),
              const SizedBox(height: 15),

              TextField(
                controller: dateFilter,

                readOnly: true,

                decoration: const InputDecoration(
                  labelText: "Date",

                  suffixIcon: Icon(Icons.calendar_today),

                  border: OutlineInputBorder(),
                ),

                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,

                    firstDate: DateTime(2020),

                    lastDate: DateTime(2030),

                    initialDate: DateTime.now(),
                  );

                  if (picked != null) {
                    String formatted =
                        "${picked.day.toString().padLeft(2, '0')}-"
                        "${picked.month.toString().padLeft(2, '0')}-"
                        "${picked.year}";

                    setState(() {
                      dateFilter.text = formatted;
                    });
                  }
                },
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF0B1325)),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0B1325),
              ),
              onPressed: () {
                applyFilter();

                Navigator.pop(context);
              },

              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Top Cards
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Total Changes",
                    summary?.totalChanges.toString() ?? "0",
                    Icons.change_circle,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _statCard(
                    "Total Users",
                    summary?.totalUsers.toString() ?? "0",
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _statCard(
                    "Active Users",
                    summary?.activeUsers.toString() ?? "0",
                    Icons.person,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _statCard(
                    "Inactive Users",
                    summary?.inactiveUsers.toString() ?? "0",
                    Icons.person_off,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// Audit Card
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    /// Header
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
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed: () {
                              _showFilterDialog();
                            },
                            icon: const Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 10),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.refresh,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
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
                          );
                        },
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

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 8),

              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
