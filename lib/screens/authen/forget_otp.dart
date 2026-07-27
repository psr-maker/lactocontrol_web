import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lactosure_control/screens/authen/change_pw.dart';
import 'package:lactosure_control/services/authen_service.dart';
import 'package:lactosure_control/widgets/custom_button.dart';

class ForgetOtp extends StatefulWidget {
  final String email;

  const ForgetOtp({super.key, required this.email});

  @override
  State<ForgetOtp> createState() => _ForgetOtpState();
}

class _ForgetOtpState extends State<ForgetOtp> {
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  int secondsRemaining = 300;

  Timer? timer;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();

    secondsRemaining = 300;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get timerText {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();

    for (var controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Image.asset(
              "assets/bglogo.png",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
            
                        const SizedBox(height: 20),
            
                        Text(
                          "A 6 digit OTP has been sent to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            
                        const SizedBox(height: 40),
            
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 50,
            
                              child: TextField(
                                controller: controllers[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
            
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
            
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
            
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
            
                        /// TIMER
                        Text(
                          timerText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
            
                        const SizedBox(height: 20),
            
                        /// RESEND OTP
                        TextButton(
                          onPressed: secondsRemaining == 0
                              ? () {
                                  startTimer();
            
                                  /// RESEND OTP API HERE
                                }
                              : null,
                          child: Text(
                            secondsRemaining == 0
                                ? "Resend OTP"
                                : "Resend available after timer",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
            
                        const SizedBox(height: 40),
            
                        CustomButton(
                          text: "Verify OTP",
            
                          onPressed: () async {
                            String otp = controllers.map((e) => e.text).join();
            
                            setState(() {
                              _isLoading = true;
                            });
            
                            final result =
                                await AuthService.forgotPasswordVerifyOtp(
                                  widget.email,
                                  otp,
                                );
            
                            setState(() {
                              _isLoading = false;
                            });
            
                            if (result["success"]) {
                              CustomSnackbar.show(
                                context: context,
                                message: result["message"],
                              );
            
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChangePassword(email: widget.email),
                                ),
                              );
                            } else {
                              CustomSnackbar.show(
                                context: context,
                                message: result["message"],
                                isError: true,
                              );
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
        ],
      ),
    );
  }
}
