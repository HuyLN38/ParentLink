import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:parent_link/theme/app.theme.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Apptheme.colors.blue,
        unselectedItemColor: Colors.grey,
        // elevation: 0,
        // Add these properties to hide the labels
         showSelectedLabels: false,
         showUnselectedLabels: false,    
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.home),
            activeIcon: Icon(IconlyBold.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.calendar),
            activeIcon: Icon(IconlyBold.calendar),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.message),
            activeIcon: Icon(IconlyBold.message),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.profile),
            activeIcon: Icon(IconlyBold.profile),
            label: '',
          ),
        ],
      );
  }
}
