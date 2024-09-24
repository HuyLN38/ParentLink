import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:navigation_view/item_navigation_view.dart';
import 'package:navigation_view/navigation_view.dart';
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
    return NavigationView(
      onChangePage: (index) {
        onTap(index); 
      },
      curve: Curves.fastEaseInToSlowEaseOut,
      durationAnimation: const Duration(milliseconds: 400),
      backgroundColor: Apptheme.colors.white,
      color: Apptheme.colors.blue,
      items: [
        _buildItem(0, IconlyBold.home, IconlyBroken.home),
        _buildItem(1, IconlyBold.calendar, IconlyBroken.calendar),
        _buildItem(2, IconlyBold.message, IconlyBroken.message),
        _buildItem(3, IconlyBold.profile, IconlyBroken.profile),
      ],
    );
  }

  ItemNavigationView _buildItem(int index, IconData iconBold, IconData iconBroken) {
    return ItemNavigationView(
      childAfter: Icon(
        iconBold,
        color: currentIndex == index ? Apptheme.colors.blue : Apptheme.colors.gray,
        size: 35,
      ),
      childBefore: Icon(
        iconBroken,
        color: Apptheme.colors.gray,
        size: 30,
      ),
    );
  }
}
