
import 'package:flutter/material.dart';

class ControlMainUser extends ChangeNotifier {
  String _username = 'Parent';
  String _phoneNumber = '';
  String _image = 'assets/img/avatar_mom.png';  // Default image

  String get username => _username;
  String get phoneNumber => _phoneNumber;
  String get image => _image;

  void updateUser(String username, String phoneNumber, String image) {
    _username = username;
    _phoneNumber = phoneNumber;
    _image = image;
    notifyListeners(); 
  }
}



