import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/admin/adminscren.dart';
import 'package:lactosure_control/screens/authen/forget_pw.dart';
import 'package:lactosure_control/screens/authen/register.dart';
import 'package:lactosure_control/screens/users/dashboard/home.dart';
import 'package:lactosure_control/services/authen_service.dart';
import 'package:lactosure_control/widgets/custom_button.dart';
import 'package:lactosure_control/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff0B1E4D), Color(0xff1E293B)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Center(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 20),
                  ],
                ),
                        
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        
                      SizedBox(height: 10),
                        
                      Text(
                        "Login to continue",
                        style: TextStyle(color: Colors.white70),
                      ),
                        
                      SizedBox(height: 35),
                        
                      CustomTextField(
                        hintText: "Email",
                        prefixIcon: Icons.email,
                        controller: emailController,
                      ),
                        
                      SizedBox(height: 20),
                        
                      CustomTextField(
                        hintText: "Password",
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        controller: passwordController,
                      ),
                        
                      SizedBox(height: 15),
                        
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgetPassword(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 255, 157, 10),
                            ),
                          ),
                        ),
                      ),
                        
                      SizedBox(height: 10),
                        
                      CustomButton(
                        text: "Login",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            final result = await AuthService.loginUser(
                              emailController.text,
                              passwordController.text,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            if (result["success"]) {
                              String email = result["email"];
                        
                              // Admin
                              if (email.toLowerCase() == "admin") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminScreen(),
                                  ),
                                );
                              }
                              // User
                              else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Dashboardhome(),
                                  ),
                                );
                              }
                              //}
                            } else {
                              CustomSnackbar.show(
                                context: context,
                                message: result["message"],
                                isError: true,
                              );
                            }
                          }
                        },
                        isLoading: _isLoading,
                        buttonclr: const Color.fromARGB(
                          255,
                          255,
                          157,
                          10,
                        ),
                        txtclr: Colors.white,
                      ),
                        
                      SizedBox(height: 25),
                        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                        
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterUser(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 157, 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
