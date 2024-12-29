import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/helper/avatar_manager.dart';
import 'package:parent_link/model/control/control_main_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final uuid = Uuid();
  File? _selectedImage;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _image;
  final apis = Apis();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadInitialUserData();
  }

  Future<void> _loadInitialUserData() async {
    final user = Provider.of<ControlMainUser>(context, listen: false);
    if (user != null) {
      _nameController.text = user.username;
      _phoneController.text = user.phoneNumber;
      _image = user.image; 
      // await _loadProfileImage(user);
    }
  }

  // Future<void> _loadProfileImage(ControlMainUser user) async {
  //   final directory = await _getAvatarDirectory();
  //   final profileImageFile = File('${directory.path}/${user.username}_avatar.jpg');
  //   if (profileImageFile.existsSync()) {
  //     setState(() {
  //       _selectedImage = profileImageFile;
  //     });
  //   }
  // }

  Future<void> _pickImage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('token');
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final pickedImageFile = File(pickedFile.path);
        final imageName = '${userID}.jpg';
        final avatarFile = await _saveAvatarImage(pickedImageFile, imageName);
        _saveChanges();

        setState(() {
          _selectedImage = avatarFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<File> _saveAvatarImage(File imageFile, String imageName) async {
    final directory = await _getAvatarDirectory();
    final avatarFile = File('${directory.path}/$imageName');
    await imageFile.copy(avatarFile.path);
    return avatarFile;
  }

  Future<Directory> _getAvatarDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${directory.path}/avatars');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    return avatarDir;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User token not found.")),
      );
      return;
    }

    try {
      String? avatarUrl;
      //sent to homemake sever
        avatarUrl = await uploadAvatar(_selectedImage!, token);

// sent to firebase 
      await apis.updateUser(
        token,
        _nameController.text,
        _phoneController.text,
        image: avatarUrl,
      );
// save to notifer
      Provider.of<ControlMainUser>(context, listen: false).updateUser(
        _nameController.text,
        _phoneController.text,
        avatarUrl ?? "assets/img/avatar_mom.png",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  Future<String> uploadAvatar(File image, String token) async {
    final avatarDir = await _getAvatarDirectory();

        final base64Image =
        await AvatarManager().processImageForUpload(image);

    final Map<String, dynamic> requestBody = {"avatar": base64Image};

   var response = await http.post(
      Uri.parse('https://huyln.info/parentlink/users/$token/avatar'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
    print('Avatar uploaded successfully');
  } else {
    throw Exception('Failed to upload avatar: ${response.statusCode}');
  }
    
    return '${avatarDir.path}/${image.uri.pathSegments.last}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Apptheme.colors.white,
      body: Consumer<ControlMainUser>(builder: (context, user, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 24),
                    ),
                    const Spacer(flex: 2),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Apptheme.colors.blue,
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: user.image!=null && user.image.isNotEmpty
                          ? FileImage(File(user.image)) 
                          : AssetImage('assets/img/avatar_mom.png') as ImageProvider,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    right: screenWidth * 0.3,
                    child: IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_camera),
                      iconSize: 30,
                      color: Apptheme.colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              _inputItem("Name", _nameController),
              _inputItem("Phone Number", _phoneController),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Apptheme.colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save changes",
                    style: TextStyle(
                      color: Apptheme.colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _inputItem(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
