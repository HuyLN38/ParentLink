import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:parent_link/theme/app.theme.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? role;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white, 
        child: GNav(
          gap: 8,
          activeColor: Apptheme.colors.blue, 
          color: Colors.grey, 
          tabBackgroundColor: Colors.blue.withOpacity(0.1), 
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onTabChange: onTap, 
          selectedIndex: currentIndex,
          tabs: role == 'parent'
              ? [
                  const GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  const GButton(
                    icon: Icons.map,
                    text: 'Map',
                  ),
                  const GButton(
                    icon: Icons.message,
                    text: 'Message',
                  ),
                  const GButton(
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ]
              : [
                  const GButton(
                    icon: Icons.message,
                    text: 'Message',
                  ),
                  const GButton(
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ],
        ),
    );
  }
}
