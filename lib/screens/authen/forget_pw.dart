import 'package:flutter/material.dart';
import 'package:lactosure_control/screens/authen/forget_otp.dart';
import 'package:lactosure_control/services/authen_service.dart';
import 'package:lactosure_control/widgets/custom_button.dart';
import 'package:lactosure_control/widgets/custom_textfield.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/login_bg.png", fit: BoxFit.cover),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          Align(
            child: Container(
              alignment: Alignment.centerRight,
              width: 480,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Color(0xff0B1E4D).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 20),
                      ],
                    ),
                    child: Form(
                      key: formKey,

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            "Enter your registered email",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 50),

                          CustomTextField(
                            hintText: "Enter Email",
                            prefixIcon: Icons.email,
                            controller: emailController,

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter email";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          CustomButton(
                            text: "Send OTP",

                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });

                                final result =
                                    await AuthService.forgotPasswordSendOtp(
                                      emailController.text,
                                    );

                                setState(() {
                                  _isLoading = false;
                                });

                                if (result["success"]) {
                                  CustomSnackbar.show(
                                    context: context,
                                    message: result["message"],
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgetOtp(
                                        email: emailController.text,
                                      ),
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
                            },

                            buttonclr: const Color.fromARGB(255, 255, 157, 10),
                            txtclr: Colors.white,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
