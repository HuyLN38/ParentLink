import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/components/button_login_page.dart';
import 'package:parent_link/theme/app.theme.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                  width:350, 
                  height: 350, 
                  decoration:  BoxDecoration(
                    color: Apptheme.colors.blue_50, 
                    shape: BoxShape.circle, 
                  ),
                  child: Center(
                      // Container for logo with shadow
                      child: SvgPicture.asset(
                        'assets/img/logo.svg',
                        height: 200, 
                      ),
                    ),
                               ),
               ),
          
              //container login
              Container(
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
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Register button
                     ButtonLoginPage(onPressed: (){Navigator.pushNamed(context, '/f2p_page');}, text: 'Register', color: null,),
                      const SizedBox(height: 8.0),
                      Divider(
                        color: Apptheme.colors.gray,
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 8.0),
                      // Login with Google
                     ButtonLoginPage(onPressed: (){}, text: 'Continue with Google', color: Apptheme.colors.white,),


                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8,),
                    
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                    "Already have an account? ",
                    style: TextStyle(color: Apptheme.colors.gray),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login_page');
                    },
                    child: Text(
                      "Login", 
                      style: TextStyle(color: Apptheme.colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Apptheme.colors.blue,
                      ),
                    ),
                  ),
                ],
              )
          
          
            ],
          ),
        ),
      ),
    );
  }
}
