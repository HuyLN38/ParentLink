import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/theme/app.theme.dart';

class ButtonLoginPage extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  final Color? color;

  const ButtonLoginPage({super.key, required this.onPressed, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    if(color == null) 
    return ElevatedButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed!(); 
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Apptheme.colors.blue_50, 
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Apptheme.colors.black, 
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 16,
          ),
        ),
      ),
    );

//login with google
    return ElevatedButton(
      onPressed: () {
        // Handle login action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Apptheme.colors.black, // Border color
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SvgPicture.asset(
              'lib/img/goggle.svg',
              height: 24,
            ),
          ),
          const Text(
            'Continue with Google',
            style: TextStyle(
              color: Colors.black, // Text color
              fontSize: 16,
            ),
          ),
        ],
      ),
    );

  }
}
