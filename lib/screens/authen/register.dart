import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/authen/otp_verify.dart';
import 'package:lactosure_control/services/authen_service.dart';
import 'package:lactosure_control/widgets/custom_button.dart';
import 'package:lactosure_control/widgets/custom_textfield.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Future<void> register() async {
    setState(() {
      _isLoading = true;
    });
    final result = await AuthService.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });

    if (result["success"]) {
      CustomSnackbar.show(context: context, message: result["message"]);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerify(email: emailController.text),
        ),
      );
    } else {
      CustomSnackbar.show(
        context: context,
        message: result["message"],
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 25, 83),
              Color.fromARGB(255, 55, 61, 71),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Register to continue",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// NAME
                      CustomTextField(
                        hintText: "Full Name",
                        prefixIcon: Icons.person,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// EMAIL
                      CustomTextField(
                        hintText: "Email",
                        prefixIcon: Icons.email,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your Email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      CustomTextField(
                        hintText: "Password",
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your Password";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// REGISTER BUTTON
                      CustomButton(
                        text: "Register",
                        isLoading: _isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            register();
                          }
                        },
                        buttonclr: Color.fromARGB(255, 255, 157, 10),
                        txtclr: Colors.white,
                      ),

                      const SizedBox(height: 25),

                      /// LOGIN OPTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Login",
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
