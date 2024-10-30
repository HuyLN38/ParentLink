import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:parent_link/theme/app.theme.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? role;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.role,
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
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: role == 'parent'
          ? const [
              BottomNavigationBarItem(
                icon: Icon(IconlyLight.home),
                activeIcon: Icon(IconlyBold.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(IconlyLight.location),
                activeIcon: Icon(IconlyBold.location),
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
            ]
          : const [
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
