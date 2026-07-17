import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/admin/dashboard/dashboardpage.dart';
import 'package:lactosure_control/screens/admin/dashboard/settings.dart';
import 'package:lactosure_control/screens/admin/users/userspage.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0;

  List<Widget> get desktopPages {
    return [DashboardPage(), UsersPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1325),
      appBar: AppBar(
        backgroundColor: Color(0xFF11192A),
        foregroundColor: Color(0xFF0B1325),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Color.fromARGB(255, 7, 218, 218),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          _buildTopNavItem("Dashboard", 0),
          const SizedBox(width: 15),

          _buildTopNavItem("Users", 1),
          const SizedBox(width: 15),

          // _buildTopNavItem("Society", 2),
          // const SizedBox(width: 15),

          // _buildTopNavItem("Machine", 3),
          // const SizedBox(width: 15),

          // // Desktop Only
          // _buildTopNavItem("BLE", 4),
          // const SizedBox(width: 15),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color.fromARGB(255, 7, 218, 218),
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Settings()),
              );
            },
          ),
        ],
      ),

      body: IndexedStack(index: selectedIndex, children: desktopPages),
    );
  }

  Widget _buildTopNavItem(String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Color.fromARGB(255, 7, 218, 218)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
