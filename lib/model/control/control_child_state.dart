import 'package:flutter/material.dart';
import 'package:parent_link/model/child_state.dart';

class ControlChildState extends ChangeNotifier {
  //list child's state 
  List <ChildState> listChild = [
    ChildState("Leslie", "On the math lesson", 652, 80, "Idle",'assets/img/child1.png'),
    ChildState("Jane", "On the school grounds", 1826, 50, "Moving",'assets/img/child2.png'),
    ChildState("Sam", "On the way home", 82, 20, "Disconnected",'assets/img/child3.png'),
    ChildState("Leslie", "On the math lesson", 652, 80, "Idle",'assets/img/child1.png'),
  
  ];

  //get list of child's state
  List<ChildState> get getlistChild => listChild;
}
