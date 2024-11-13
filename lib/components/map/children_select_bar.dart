import 'package:flutter/material.dart';
import '../../model/child.dart';

class ChildAvatarBar extends StatelessWidget {
  final List<Child> children;
  final Function(Child) onChildTap;
  final bool isVisible;
  final VoidCallback onToggle;

  const ChildAvatarBar({
    Key? key,
    required this.children,
    required this.onChildTap,
    required this.isVisible,
    required this.onToggle,
  }) : super(key: key);

  Widget _buildChildAvatar(Child child) {
    return GestureDetector(
      onTap: () => onChildTap(child),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/img/child1.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 30,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isVisible ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          left: isVisible ? 16 : -80,
          top: 50,
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  children.map((child) => _buildChildAvatar(child)).toList(),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          left: isVisible ? -30 : 0,
          top: 50,
          child: _buildSwipeIndicator(),
        ),
      ],
    );
  }
}
