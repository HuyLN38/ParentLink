import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parent_link/theme/app.theme.dart';

class ButtonOpenPage extends StatefulWidget {
  final Function()? onTap;
  final String text;

  const ButtonOpenPage({super.key, required this.onTap, required this.text});

  @override
  State<ButtonOpenPage> createState() => _ButtonOpenPageState();
}

class _ButtonOpenPageState extends State<ButtonOpenPage> {
  bool isClicked = false; 

  void toggleClicked() {
    setState(() {
      isClicked = !isClicked;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggleClicked(); // Toggle color on click
        if (widget.onTap != null) {
          widget.onTap!(); // Call the provided onTap function
        }
      },
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: isClicked ? Apptheme.colors.white : Apptheme.colors.blue_50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Apptheme.colors.white,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(50, 50, 93, 0.25),
                offset: Offset(0, 50),
                blurRadius: 100,
                spreadRadius: -20,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                offset: Offset(0, 30),
                blurRadius: 60,
                spreadRadius: -30,
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: isClicked ? Apptheme.colors.blue_50 : Apptheme.colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      );
  }
}
