import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/admin/adminscren.dart';
import 'package:lactosure_control/screens/authen/login.dart';
import 'package:lactosure_control/constant/global/token.dart';
import 'package:lactosure_control/screens/users/dashboard/home.dart';
import 'package:lactosure_control/services/authen_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    checkLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 4));

    try {
      final loggedIn = await TokenCheck.isLoggedIn();

      if (!mounted || _navigated) return;
      _navigated = true;

      if (loggedIn) {
        final email = await TokenCheck.getEmail();

        if (!mounted) return;

        if (email != null && email.toLowerCase().contains("admin")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Dashboardhome()),
          );
        }
      } else {
        await AuthService.logout();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/psrlogo.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
