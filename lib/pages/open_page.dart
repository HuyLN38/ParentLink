import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parent_link/components/button_open_page.dart';
import 'package:parent_link/theme/app.theme.dart';

class OpenPage extends StatelessWidget {
  const OpenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.colors.blue_50,
      body: Center( 
        child: Column(
          children: [
            //logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Container(
                decoration:const BoxDecoration(
                  boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(50, 50, 93, 0.25),
                    offset: Offset(0, 50),
                    blurRadius: 100, 
                    spreadRadius: -20, 
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    offset: Offset(0, 30), 
                    blurRadius: 60, 
                    spreadRadius: -30, 
                  ),
                  ]
                ),
                child: SvgPicture.asset(
                  'lib/img/logo.svg',
                  height: 300,
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
    );
  }
}
