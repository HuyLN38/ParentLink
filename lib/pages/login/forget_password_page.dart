import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/components/button_login_page.dart';
import 'package:parent_link/theme/app.theme.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo at the top of the screen
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
                  'lib/img/logo.svg',
                  height: 200, 
                ),
              ),
            ),
          ),
          
          // Space between logo and form
          const SizedBox(height: 40),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                    border: Border.all(
                      color: Apptheme.colors.gray_light,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      Text(
                        "No User Found",
                        style: TextStyle(color: Apptheme.colors.red),
                      ),

                      const SizedBox(height: 16.0),

                      // Submit button
                     ButtonLoginPage(onPressed: (){}, text: 'Submit', color: null,),
                    ],
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
