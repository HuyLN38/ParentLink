import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/theme/app.theme.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //logo
               Container(
                width:350, 
                height: 350, 
                decoration:  BoxDecoration(
                  color: Apptheme.colors.blue_50, 
                  shape: BoxShape.circle, 
                ),
                child: Center(
                    // Container for logo with shadow
                    child: SvgPicture.asset(
                      'lib/img/logo.svg',
                      height: 200, 
                    ),
                  ),
              ),
          
              //container login
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25), 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      offset: const Offset(0, 3),
                      blurRadius: 8, 
                    ),
                  ],
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
                        "No User Found ",
                        style: TextStyle(color: Apptheme.colors.red),
                        ),

                      const SizedBox(height: 16.0),

                      // Submit button
                      GestureDetector(
                        onTap: () {
                          // Handle Submit action
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Apptheme.colors.blue_50,
                            border: Border.all(
                              color: Apptheme.colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
