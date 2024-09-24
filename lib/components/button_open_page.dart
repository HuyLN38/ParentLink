import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class ButtonOpenPage extends StatefulWidget {
  final Function()? onTap;
  final String text;

  const ButtonOpenPage({super.key, required this.onTap, required this.text});

  @override
  State<ButtonOpenPage> createState() => _ButtonOpenPageState();
}

class _ButtonOpenPageState extends State<ButtonOpenPage>
    with SingleTickerProviderStateMixin {
  bool isClicked = false;
  double _buttonScale = 1;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setClicked(bool clicked) {
    setState(() {
      isClicked = clicked;
    });
  }

  void _startAnimation() {
    _controller.forward();
  }

  void _reverseAnimation() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _buttonScale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) {
        _startAnimation();
        setClicked(true);
      },
      onTapUp: (_) {
        _reverseAnimation();
        setClicked(false);
        if (widget.onTap != null) {
          widget.onTap!(); // Call the provided onTap function
        }
      },
      onTapCancel: () {
        _reverseAnimation();
        setClicked(false); // Reset when activity cancle
      },
      child: Transform.scale(
        scale: _buttonScale, // Use scale to create effect "pressed"
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: isClicked ? Apptheme.colors.blue_50 : Apptheme.colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Apptheme.colors.white,
              width: 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: isClicked ? Apptheme.colors.white : Apptheme.colors.blue_50,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
