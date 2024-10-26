import 'package:parent_link/pages/login/children_qr.dart';
import 'package:parent_link/pages/login/f2p_page.dart';
import 'package:parent_link/pages/login/forget_password_page.dart';
import 'package:parent_link/pages/login/login_page.dart';
import 'package:parent_link/pages/login/register_page.dart';
import 'package:parent_link/pages/login/send_mail_page.dart';
import 'package:parent_link/pages/main_page.dart';
import 'package:parent_link/pages/open_page.dart';
import 'package:parent_link/pages/profile/edit_profile_page.dart';

class Routes {
  final routes = {
    '/open_page': (context) => const OpenPage(),
    '/login_page': (context) => const LoginPage(),
    '/register_page': (context) => const RegisterPage(),
    '/forget_password_page': (context) => const ForgetPasswordPage(),
    '/send_mail_page': (context) => const SendMailPage(),
    '/f2p_page': (context) => const F2pPage(),
    '/edit_profile_page': (context) => const EditProfilePage(),
    '/main_page': (context) => const MainPage(),
    '/children_qr': (context) => const ChildrenQr(),
  };
  Routes();
}
