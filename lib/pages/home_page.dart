import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isNotified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // add child activity
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Apptheme.colors.black,
                          width: 1,
                        ),
                      ),
                      child: const Text("Add a child"),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // handle notification activity
                      setState(() {
                        _isNotified = !_isNotified; 
                      });
                    },
                    child: Icon(
                      _isNotified
                          ? Icons.notifications
                          : Icons.notifications_none, 
                      size: 36.0,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30,),

            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 25.0),
                child: Text("Hello Sarah", 
                style: TextStyle(
                  fontSize: 30,
                )
                ),
              ),
            ),
            const SizedBox(height: 8,),

              Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text("There are current new alert", 
                style: TextStyle(
                  fontSize: 16,
                  color: Apptheme.colors.gray,
                )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
