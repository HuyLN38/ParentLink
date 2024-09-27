import 'package:flutter/material.dart';
import 'package:parent_link/model/control_child_state.dart';
import 'package:provider/provider.dart'; // Ensure you have this import
import 'package:parent_link/pages/login/forget_password_page.dart';
import 'package:parent_link/pages/login/login_page.dart';
import 'package:parent_link/pages/main_page.dart';
import 'package:parent_link/pages/open_page.dart';
import 'package:parent_link/pages/login/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControlChildState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OpenPage(),
        routes: {
          '/open_page': (context) => const OpenPage(),
          '/login_page': (context) => const LoginPage(),
          '/register_page': (context) => const RegisterPage(),
          '/forget_password_page': (context) => const ForgetPasswordPage(),
          '/main_page': (context) => const MainPage(),
        },
      ),
    );
  }
}
