
import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/components/button_open_page.dart';
import 'package:parent_link/theme/app.theme.dart';

class OpenPage extends StatelessWidget {
  const OpenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Apptheme.colors.blue_50,
      body: SingleChildScrollView(
        child: Center( 
          child: Column(
            children: [
              //logo
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 50.0),
             child: Container(
              height: 320,
              width: 320,
              child: Animator<double>(
                duration: Duration(milliseconds: 2000),
                cycles: 0,
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 0.0, end: 10.0),
                builder: (context, animatorState, child) => Column(
                  children: [
                    SizedBox(
                      height: animatorState.value * 2,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          // BoxShadow(
                          //   color: Apptheme.colors.gray_light,
                          //   blurRadius: 20,
                          //   offset: Offset(0, 5),
                          // ),
                        ],
                      ),
                     child: SvgPicture.asset(
                          'lib/img/logo.svg',
                          height: 250, 
                        ),
                    ),
                  ],
                ),
              ),
                       ),
           ),
        
              //parent button
              ButtonOpenPage(onTap: () => Navigator.pushNamed(context, '/login_page'), text: 'Parent'),
        
              const SizedBox(height: 25,),
        
            //child button
             ButtonOpenPage(onTap: () => {}, text: 'Children'),
            ],
          ),
        ),
      ),
    );
  }
}
