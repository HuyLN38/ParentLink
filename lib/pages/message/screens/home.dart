import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/helper/uuid.dart' as globals;
import 'package:parent_link/pages/message/widgets/chat_user_card.dart';
import 'package:parent_link/theme/app.theme.dart';

import '../../../model/chat/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  List<ChatUser> searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
    Apis.updateActiveStatus(true);

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (globals.token != null) {
        if (message?.contains('resume') ?? false) {
          Apis.updateActiveStatus(true);
        } else if (message?.contains('pause') ?? false) {
          Apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (isSearching) {
            setState(() {
              isSearching = false;
            });
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Apptheme.colors.blue,
      centerTitle: true,
      elevation: 1,
      leadingWidth: isSearching ? null : 215,
      leading: isSearching
          ? null
          : FutureBuilder(
        future: Apis.getSelfInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          }

          return Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: (Apis.me.image != null &&
                      Apis.me.image!.isNotEmpty &&
                      Apis.me.image != 'assets/img/avatar_mom.png')
                      ? FileImage(File(Apis.AvatarPath))
                      : const AssetImage('assets/img/avatar_mom.png')
                  as ImageProvider,
                ),
                const SizedBox(width: 12),
                Text(
                  Apis.me.name ?? "Failed to display",
                  style: TextStyle(
                    color: Apptheme.colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      title: isSearching
          ? TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Name, Email...',
          hintStyle: TextStyle(color: Apptheme.colors.white),
        ),
        autofocus: true,
        style: TextStyle(
          fontSize: 18,
          letterSpacing: 0.5,
          color: Apptheme.colors.white,
        ),
        onChanged: (value) {
          searchList = list
              .where((user) =>
          user.name!.toLowerCase().contains(value.toLowerCase()) ||
              user.email!
                  .toLowerCase()
                  .contains(value.toLowerCase()))
              .toList();
          setState(() {});
        },
      )
          : null,
      actions: [
        _buildSearchButton(),
        IconButton(
          onPressed: _addChatUserDialog,
          icon: Icon(
            Icons.person_add_rounded,
            color: Apptheme.colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return Container(
      decoration: BoxDecoration(
        color: Apptheme.colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            isSearching = !isSearching;
            if (!isSearching) searchList.clear();
          });
        },
        icon: Icon(isSearching ? Icons.cancel : Icons.search),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Apptheme.colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Apptheme.colors.blue,
            spreadRadius: 15,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder(
              stream: Apis.getMyUsersId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Users Found'));
                }

                final userIds =
                    snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                if (userIds.isEmpty) {
                  return const Center(child: Text('No Users Found'));
                }

                return StreamBuilder(
                  stream: Apis.getAllUser(userIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No Users Found'),
                      );
                    }

                    list = snapshot.data!.docs
                        .map((e) => ChatUser.fromJson(e.data()))
                        .toList();

                    final displayList = isSearching ? searchList : list;

                    return ListView.builder(
                      itemCount: displayList.length,
                      padding: const EdgeInsets.only(top: 10),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: displayList[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Chats",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: () {
              // Add your manage button action here
            },
            child: const Text(
              "Manage",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addChatUserDialog() {
    String userId = '';
    final addChatUserKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: const Row(
          children: [
            Icon(Icons.add, color: Colors.blue, size: 28),
            Text(' Add User by ID'),
          ],
        ),
        content: Form(
          key: addChatUserKey,
          child: TextFormField(
            onChanged: (value) => userId = value.trim(),
            decoration: const InputDecoration(
              hintText: 'User ID',
              prefixIcon: Icon(Icons.person_outline, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a valid user ID';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              if (addChatUserKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                await _addChatUserById(userId);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _addChatUserById(String userId) async {
    final userExists = await Apis.addChatUserById(userId);
    if (!userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User does not exist!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
