import 'package:flutter/material.dart';
import 'package:parent_link/theme/colors.dart';

@immutable
class Apptheme {
  static const colors = AppColors();
  const Apptheme._();
  static ThemeData define(){
    return ThemeData();
  }
}