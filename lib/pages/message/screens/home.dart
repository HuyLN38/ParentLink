import 'package:parent_link/api/apis.dart';
import 'package:parent_link/model/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:parent_link/pages/message/widgets/chat_user_card.dart';

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
        if (Apis.auth.currentUser != null) {
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
            centerTitle: true,
            elevation: 1,
            title: isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email...',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 18, letterSpacing: 0.5),
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
                : const Text('Home Page'),
            leading: const Icon(Icons.home),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                  icon: Icon(isSearching ? Icons.cancel : Icons.search)),
              IconButton(
                  onPressed: () {
                    _addChatUserDialog();
                  },
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.blueAccent,
                  )),
            ],
          ),
  
          body: StreamBuilder(
            stream: Apis.getMyUsersId(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('An error occurred'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No Users Found'));
              } 
              
              else {
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
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (list.isNotEmpty) {
                          return ListView.builder(
                            itemCount:
                                isSearching ? searchList.length : list.length,
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
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';
    final _addChatUserKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Add User')
                ],
              ),

              //content
              content: Form(
                key: _addChatUserKey,
                child: TextFormField(
                  maxLines: null,
                  onChanged: (value) => email = value,
                  decoration: const InputDecoration(
                      hintText: 'Email Id',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.blueAccent,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)))),
                  validator: (value) {
                    if (value == null ||
                        !value.contains('@') ||
                        value.trim().isEmpty) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //Add button
                MaterialButton(
                    onPressed: () async {
                      final isValid = _addChatUserKey.currentState!.validate();
                      if (isValid) {
                        Navigator.pop(context);
                        await Apis.addChatUser(email).then(
                          (value) {
                            if (!value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          const Text('User does not exists!'),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      behavior: SnackBarBehavior.floating));
                            }
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
