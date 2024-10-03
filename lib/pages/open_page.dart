import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/components/button_open_page.dart';
import 'package:parent_link/theme/app.theme.dart';

class OpenPage extends StatelessWidget {
  const OpenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildWebLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildAnimatedLogo(),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildButtonSection(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          _buildAnimatedLogo(),
          const Spacer(),
          _buildButtonSection(context),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return SizedBox(
      height: 320,
      width: 320,
      child: Animator<double>(
        duration: const Duration(milliseconds: 2000),
        cycles: 0,
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0.0, end: 10.0),
        builder: (context, animatorState, child) => Column(
          children: [
            SizedBox(height: animatorState.value * 2),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/img/logo.svg',
                height: 250,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ButtonOpenPage(
            onTap: () => Navigator.pushNamed(context, '/login_page'),
            text: 'Parent',
          ),
          const SizedBox(height: 25),
          ButtonOpenPage(
            onTap: () {},
            text: 'Children',
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Apptheme.colors.blue_50,
                Colors.blue.shade100,
                Colors.blue.shade200,
              ],
              stops: [
                0,
                _controller.value,
                1,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
 