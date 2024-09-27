import 'package:flutter/material.dart';
import 'package:parent_link/components/child_state_tile.dart';
import 'package:parent_link/model/child_state.dart';
import 'package:parent_link/model/control_child_state.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    //access child' state list 
    final childStateList = context.watch<ControlChildState>().childList;

    return
    Scaffold(
      backgroundColor: Colors.white,
      body:Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                ElevatedButton(
                  onPressed: () {
                    // Add child activity
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    backgroundColor: Apptheme.colors.white, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Apptheme.colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Add a child",
                    style: TextStyle(
                      color: Colors.black, // Text color
                    ),
                  ),
                ),


                     IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: (){
                        //do sth acitivity
                      },
                      iconSize: 36.0,
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

            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: childStateList.length,
                itemBuilder: (context, index) {
                  final childeState = childStateList[index];
                  return ChildStateTile(childState: childeState, index: index,);
                })
            )


          ],
        ),
    );
  }
}
