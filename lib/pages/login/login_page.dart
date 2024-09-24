import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/theme/app.theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text("Login"),
      // ),
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
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Login button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/main_page');
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
                              'Login',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Divider(
                        color: Apptheme.colors.gray,
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 8.0),
                      // Login with Google
                      GestureDetector(
                        onTap: () {
                          // Handle login action
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Apptheme.colors.white,
                            border: Border.all(
                              color: Apptheme.colors.black,
                              width: 1,
                            ),
                          ),
                          child: Row(
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
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8,),
          
              GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, '/forget_password_page');
                },
                child: Text("Forgot Password", style: TextStyle(color: Apptheme.colors.gray),)),
          
              const SizedBox(height: 8,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have no account yet? ",
                    style: TextStyle(color: Apptheme.colors.gray),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register_page');
                    },
                    child: Text(
                      "Create one", 
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
