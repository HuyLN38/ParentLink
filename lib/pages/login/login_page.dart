import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/components/button_login_page.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'package:parent_link/pages/login/handlers/AuthServices.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = Apis.auth;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final prefs = await SharedPreferences.getInstance();
    final result = await _authService.login(email, password);
    final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: email, password: password);

    setState(() async {
      _isLoading = false;
      if (result.containsKey('error')) {
        _errorMessage = result['error'];
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['localId']);
        await prefs.setString('role', 'parent');

        Navigator.pushNamed(context, '/main_page');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      height: 200,
                    ),
                  ),
                ),
              ),
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
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ButtonLoginPage(
                        onPressed: _isLoading ? null : _login,
                        text: _isLoading ? 'Logging in...' : 'Login',
                        color: null,
                      ),
                      const SizedBox(height: 8.0),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/forget_password_page');
                },
                child: Text(
                  "Forgot Password",
                  style: TextStyle(color: Apptheme.colors.gray),
                ),
              ),
              const SizedBox(height: 8),
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
                      style: TextStyle(
                        color: Apptheme.colors.blue,
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
