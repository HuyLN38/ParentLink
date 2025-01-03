import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parent_link/pages/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      "https://huyln.info/parentlink"; // Change to your server domain

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Successful login
      } else {
        return {'error': 'Wrong email or password'};
      }
    } catch (e) {
      return {'error': 'Failed to connect to the server'};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Successful registration
      } else {
        return {'error': 'Failed to register '};
      }
    } catch (e) {
      print(e);
      return {'error': 'Failed to connect to the server'};
    }
  }

  Future<Map<String, dynamic>> validOTP(String otp) async {
    final url = Uri.parse('$baseUrl/register/$otp');
    try {
      final response = await http.get(
        url,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Successful registration
      } else if (response.statusCode == 401) {
        return {'error': 'Invalid OTP'};
      } else {
        return {'error': 'Failed to validate OTP'};
      }
    } catch (e) {
      print(otp.toString());
      print(e);
      return {'error': 'Failed to connect to the server'};
    }
  }
    // Logout function 
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all SharedPreferences data
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (contect)=> LoginPage()), (Route<dynamic> route) => false,);
    } catch (e) {
      print("Error during logout: $e");
    }
  }
}

