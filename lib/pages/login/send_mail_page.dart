import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/theme/app.theme.dart';

class SendMailPage extends StatefulWidget {
  const SendMailPage({super.key});

  @override
    _SendMailPageState createState() => _SendMailPageState();
}

class _SendMailPageState extends State<SendMailPage> {
  int timeLeft = 60;
  late final Timer timer;

  @override
  void initState() {
    super.initState();

    //Countdown timer logic
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    },);  
  }

  @override
  void dispose() {
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
              //logo
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
                      height: 200,),
                  ),
                ),
                ),
                //Box covering sent mail and resend
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
                        offset: Offset(0, 3), //change position of shadow
                      ),
                    ] ,
                  ),
                  child: Column(
                    children: [
                      //Send mail instruction
                      Text(
                        'Check your a****23@gmail.com for a change password confirmation',
                        style:  TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20,),
                        Text(
                          'Send mail again in $timeLeft seconds',
                          style: TextStyle(color: Colors.grey),
                          ),
                          //Resend mail button(after 60s)
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
                                child: Text('Resend Mail'),
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