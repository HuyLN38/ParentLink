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
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Apptheme.colors.white,
      selectedItemColor: Apptheme.colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(IconlyLight.home),
          activeIcon: Icon(IconlyBold.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconlyLight.calendar),
          activeIcon: Icon(IconlyBold.calendar),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconlyLight.message),
          activeIcon: Icon(IconlyBold.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconlyLight.profile),
          activeIcon: Icon(IconlyBold.profile),
          label: 'Profile',
        ),
      ],
    );
  }
}
