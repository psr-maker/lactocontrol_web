import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/authen/login.dart';
import 'package:lactosure_control/services/authen_service.dart';
import 'package:lactosure_control/widgets/confirmdialog.dart';
import 'package:lactosure_control/widgets/custom_button.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isLoading = false;
  Future<void> logout() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 7, 218, 218),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Color.fromARGB(255, 7, 218, 218),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CustomButton(
              text: "LOGOUT",

              onPressed: _isLoading
                  ? null
                  : () async {
                      bool? confirmed = await showConfirmDialog(
                        context,
                        "Logout",
                        "this account",
                      );
                      if (confirmed == true) {
                        logout();
                      }
                    },
              isLoading: _isLoading,
              buttonclr: Theme.of(context).colorScheme.error,
              txtclr: Theme.of(context).colorScheme.onPrimary,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
