import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'dart:async';

class F2pPage extends StatefulWidget {
  const F2pPage({super.key});

  @override
  _F2pPageState createState() => _F2pPageState();
}

class _F2pPageState extends State<F2pPage> {
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;
  int timeLeft = 60;
  late final Timer timer;

  @override
  void initState() {
    super.initState();

    // Initialize OTP controllers and focus nodes
    otpControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

    // Countdown timer logic
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
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
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // OTP instruction
                    Text(
                      'Please check your inbox or another device for the OTP code to login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    // OTP input field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 40,
                          child: TextField(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false), 
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Apptheme.colors.blue),
                              ),
                              counterText: '',
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                              }
                              if (value.isEmpty && index > 0) {
                                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    // Resend OTP logic
                    Text(
                      'Send OTP again in $timeLeft seconds',
                      style: TextStyle(color: Colors.grey),
                    ),
                    // Resend OTP button (after 60 seconds)
                    timeLeft == 0
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                timeLeft = 60;
                                timer.cancel();
                                timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
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
                            child: Text('Resend OTP'),
                          )
                        : SizedBox(),
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