import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; //take current size screen
    final screenWidth = screenSize.width;
    return Scaffold(
      backgroundColor: Apptheme.colors.white,
      body: Column(
        children: [
          //top bar
          Container(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                    )),
                Spacer(
                  flex: 2,
                ),
                Text(
                  "Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Spacer(
                  flex: 3,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              //avatar
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Apptheme.colors.blue,
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/img/avatar_mom.png'),
                  ),
                ),
              ),
              //camera icon
              Positioned(
                  top: 110,
                  right: screenWidth * 1 / 3,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_camera),
                    iconSize: 30,
                    color: Apptheme.colors.black.withOpacity(0.7),
                  ))
            ],
          ),
          _inputItem("Name", "Sarah"),
          _inputItem("Email", "Sarah@gmail.com"),
          _inputItem("Phone Number", "012345678"),
          const SizedBox(
            height: 40,
          ),

          //save button
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Apptheme.colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  "Save changes",
                  style: TextStyle(
                    color: Apptheme.colors.white,
                    fontSize: 20,
                  ),
                )),
          )
        ],
      ),
    );
  }

  Widget _inputItem(String label, String inputHint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          TextField(
            decoration: InputDecoration(
              hintText: inputHint,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
