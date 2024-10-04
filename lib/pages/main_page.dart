import 'package:flutter/material.dart';
import 'package:parent_link/components/bottom_bar.dart';
import 'package:parent_link/pages/home/home_page.dart';
import 'package:parent_link/pages/message/message_page.dart';
import 'package:parent_link/pages/profile/profile_page.dart';
import 'package:parent_link/pages/map_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    //this selected index is to control the bottome nav bar
  int _selectedIndex=0;
  
  // this method will update our selected index
  // when the user tags on the bottom bar
  void navigateBottom(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  // pages to display
final List<Widget> _page =[
      //home pape
  const HomePage(),
      // scchedule page
  const SchedulePage(),
    //message page
  const MessagePage(),
    //profile page
  const ProfilePage(),


];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomBar(
      currentIndex: _selectedIndex,
      onTap: navigateBottom,
    ),

      body: _page[_selectedIndex],
    );

    
  }
}