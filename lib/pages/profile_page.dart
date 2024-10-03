import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isPushNotif = false;
  bool isDataSave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.colors.gray_light,
      body: Stack(
        children: [
          // Profile settings bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Apptheme.colors.blue,
              height: 300,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Text(
                "Profile settings",
                style: TextStyle(
                  color: Apptheme.colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),

          Positioned(
            top: 85,
            left: 8,
            right: 8,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Apptheme.colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/img/avatar_mom.png'),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Sarah",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Divider(),
                  ]
            )),)),

          // Setting 
          Positioned(
            top: 190,
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Apptheme.colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Account Settings",
                                style: TextStyle(
                                  color: Apptheme.colors.gray,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Edit profile",
                          Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Change password",
                          Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Add a payment method",
                          Icon(Icons.add, size: 25, color: Apptheme.colors.gray)),
                      const SizedBox(height: 12),
                  
                      _settingItemOnOff("Push notification", isPushNotif, (value) {
                        setState(() {
                          isPushNotif = value;
                        });
                      }),
                      _settingItemOnOff("Data save mode", isDataSave, (value) {
                        setState(() {
                          isDataSave = value; 
                        });
                      }),
                      const SizedBox(height: 12),
                      Divider(),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Text(
                            "Account Settings",
                            style: TextStyle(
                              color: Apptheme.colors.gray,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "About us",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Privacy policy",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Terms and conditions",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),


                    // test scrolling
                                              const SizedBox(height: 22),
                      _settingItem(() {}, "About us",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Privacy policy",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Terms and conditions",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),

                                                                      const SizedBox(height: 22),
                      _settingItem(() {}, "About us",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Privacy policy",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                      const SizedBox(height: 22),
                      _settingItem(() {}, "Terms and conditions",
                        Icon(Icons.arrow_forward_ios, size: 20, color: Apptheme.colors.gray)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Setting item
  Widget _settingItem(VoidCallback ontap, String text, Icon icon) {
    return GestureDetector(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          icon,
        ],
      ),
    );
  }

  // Setting item to turn on and off
  Widget _settingItemOnOff(String text, bool isSwitched, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Switch(
            value: isSwitched,
            onChanged: onChanged,
            activeColor: Apptheme.colors.blue,
            inactiveThumbColor: Apptheme.colors.white,
            inactiveTrackColor: Apptheme.colors.gray_light,
          ),
        ],
      ),
    );
  }
}
