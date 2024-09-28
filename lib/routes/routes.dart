import 'package:parent_link/pages/home/home_page.dart';
import 'package:parent_link/pages/home/location_page.dart';
import 'package:parent_link/pages/login/forget_password_page.dart';
import 'package:parent_link/pages/login/login_page.dart';
import 'package:parent_link/pages/login/register_page.dart';
import 'package:parent_link/pages/main_page.dart';
import 'package:parent_link/pages/open_page.dart';

class Routes {
  final routes = {
    '/open_page': (context) => const OpenPage(),
    '/login_page': (context) => const LoginPage(),
    '/register_page': (context) => const RegisterPage(),
    '/forget_password_page': (context) => const ForgetPasswordPage(),
    '/main_page': (context) => const MainPage(),

  };
  Routes();
}
