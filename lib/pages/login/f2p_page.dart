import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'dart:async';
import 'package:parent_link/pages/login/handlers/AuthServices.dart';
import 'package:pinput/pinput.dart';

class F2pPage extends StatefulWidget {
  const F2pPage({super.key});

  @override
  _F2pPageState createState() => _F2pPageState();
}

class _F2pPageState extends State<F2pPage> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  int timeLeft = 60;
  late final Timer timer;

  String? _errorMessage;

  void _register() async {
    setState(() {
      _errorMessage = null;
    });

    final otp = _otpController.text;

    final result = await _authService.validOTP(otp);
    setState(() {
      if (result.containsKey('error')) {
        _errorMessage = result['error'];
      } else {
        Navigator.pushNamed(context, '/login_page');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Countdown timer logic
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controllers and focus nodes
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
        width: 40,
        height: 40,
        textStyle: TextStyle(fontSize: 22, color: Apptheme.colors.black),
        decoration: BoxDecoration(
            color: Apptheme.colors.gray_light.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent)));

    return Scaffold(
      backgroundColor: Apptheme.colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    color: Apptheme.colors.blue_50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/img/logo.svg',
                      height: 200,
                    ),
                  ),
                ),
              ),
              // Box covering OTP instruction, input fields, and resend message
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // OTP instruction
                    const Text(
                      'Please check your inbox or another device for the OTP code to login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // OTP input field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Pinput(
                          controller: _otpController,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                                border:
                                    Border.all(color: Apptheme.colors.gray)),
                          ),
                          onCompleted: (pin) {
                            // Trigger OTP verification
                            _register();
                          },
                        )
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Resend OTP logic
                    Text(
                      'Send OTP again in $timeLeft seconds',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8.0),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    // Resend OTP button (after 60 seconds)
                    timeLeft == 0
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                timeLeft = 60;
                                timer.cancel();
                                timer = Timer.periodic(
                                    const Duration(seconds: 1), (Timer timer) {
                                  if (timeLeft > 0) {
                                    setState(() {
                                      timeLeft--;
                                    });
                                  } else {
                                    timer.cancel();
                                  }
                                });
                              });
                            },
                            child: const Text('Resend OTP'),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
