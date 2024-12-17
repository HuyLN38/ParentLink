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
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    Apis.getSelfInfo();
    Apis.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler(
      (message) {
        if (globals.token != null) {
          if (message.toString().contains('resume')) {
            Apis.updateActiveStatus(true);
          } else {
            Apis.updateActiveStatus(false);
          }
        }

        return Future.value(message);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
            return;
          }

          // some delay before pop
          Future.delayed(
              const Duration(milliseconds: 300), SystemNavigator.pop);
        },
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: Apptheme.colors.blue,
            centerTitle: true,
            elevation: 1,
            leadingWidth: !isSearching ? 300 : null,
            leading: !isSearching
                ? FutureBuilder(
                    future: Apis.getSelfInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Error loading profile');
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: (Apis.me.image !=
                                        'assets/img/avatar_mom.png')
                                    ? FileImage(File(Apis.AvatarPath))
                                        as ImageProvider
                                    : const AssetImage(
                                            'assets/img/avatar_mom.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Apis.me.name ?? "Fail to display",
                                style: TextStyle(
                                  color: Apptheme.colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  )
                : null,
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
                      searchList.clear();

                      for (final i in list) {
                        if (i.name!
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email!
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          searchList.add(i);
                        }

                        setState(() {
                          searchList;
                        });
                      }
                    },
                  )
                : null,
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Apptheme.colors.white,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isSearching = !isSearching;
                        });
                      },
                      icon: Icon(isSearching ? Icons.cancel : Icons.search)),
                ),
              ),
              IconButton(
                  onPressed: () {
                    _addChatUserDialog();
                  },
                  icon: Icon(
                    Icons.person_add_rounded,
                    color: Apptheme.colors.white,
                  )),
            ],
          ),
          body: Container(
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
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
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
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: Apis.getMyUsersId(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('An error occurred'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No Users Found'));
                      } else {
                        final userIds =
                            snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                        if (userIds.isEmpty) {
                          return const Center(
                            child: Text('No Users Found'),
                          );
                        }

                        return StreamBuilder(
                          stream: Apis.getAllUser(userIds),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              default:
                                final data = snapshot.data?.docs;
                                list = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                if (list.isNotEmpty) {
                                  return ListView.builder(
                                    itemCount: isSearching
                                        ? searchList.length
                                        : list.length,
                                    padding: const EdgeInsets.only(top: 10),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                        user: isSearching
                                            ? searchList[index]
                                            : list[index],
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(
                                    child: Text(
                                      'No Users Found',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  );
                                }
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String userId = '';
    final _addChatUserKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),

        // Title
        title: const Row(
          children: [
            Icon(
              Icons.add,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Add User by ID')
          ],
        ),

        // Content
        content: Form(
          key: _addChatUserKey,
          child: TextFormField(
            maxLines: null,
            onChanged: (value) => userId = value.trim(),
            decoration: const InputDecoration(
                hintText: 'User ID',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Colors.blueAccent,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a valid user ID';
              }
              return null;
            },
          ),
        ),

        // Actions
        actions: [
          MaterialButton(
            onPressed: () {
              // Hide the dialog
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              final isValid = _addChatUserKey.currentState!.validate();
              if (isValid) {
                Navigator.pop(context);
                await _addChatUserById(userId);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addChatUserById(String userId) async {
    // Call your API method with the entered user ID
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
