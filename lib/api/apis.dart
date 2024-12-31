import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:parent_link/helper/uuid.dart' as globals;
import 'package:parent_link/main.dart';
import 'package:parent_link/model/control/control_main_user.dart';
import 'package:provider/provider.dart';
import '../helper/avatar_manager.dart';
import 'dart:io';

import 'package:parent_link/api/notification_access_token.dart';
import 'package:parent_link/model/chat/chat_user.dart';
import 'package:parent_link/model/chat/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/uuid.dart';

class Apis {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static AvatarManager avatarManager = AvatarManager();

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.token = prefs.getString('token');

    await messaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        // log('Push Token: $t');
      }
    });

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      if (chatUser.pushToken == null || chatUser.pushToken!.isEmpty) {
        log('User does not have a push token.');
        return;
      }

      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name,
            "body": msg,
          },
          "android": {
            "notification": {
              "channel_id":
                  "chats", // Correct field name for android channel ID
            }
          },
          "data": {
            "some_data": "User ID: ${me.id}",
          },
        }
      };

      const projectID = 'parentlink-30210';
      final bearerToken = await NotificationAccessToken.getToken;

      if (bearerToken == null) {
        log('Firebase admin token is null. Cannot send notification.');
        return;
      }

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        log('Push notification sent successfully.');
      } else {
        log('Error sending push notification: ${res.statusCode}');
        log('Response body: ${res.body}');
      }
    } catch (e) {
      log('Error sending push notification: $e');
    }
  }

  static late ChatUser me;
  static late String AvatarPath;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(globals.token).get())
        .exists;
  }

  static Future<ChatUser?> getSelfInfo() async {
    await firestore.collection('users').doc(globals.token).get().then(
      (user) {
        if (user.exists) {
          me = ChatUser.fromJson(user.data()!);
          AvatarPath = me.image!;
          getFirebaseMessagingToken();
          return me;
        }
      },
    );
    return null;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('localId', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('users').doc(token).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // User
  static Future<void> createUser(
      String uuid, String username, String imageURL) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? parentid = sharedPreferences.getString('parentId');
    final time = Timestamp.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: uuid,
        name: username,
        createdAt: time,
        image: await AvatarManager.getOrUpdateAvatar(
            uuid,
            'https://huyln.info/parentlink/users/$parentid/children-avatar/$uuid',
            "0"),
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore.collection('users').doc(uuid).set(chatUser.toJson());
  }

  Future<void> updateUser(String userId, String name, String phone, {String? image}) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': name,
        'phoneNumber': phone,
        if (image != null) 'image': image,
        'updatedAt': Timestamp.now(),
      });
      log("Profile updated successfully!");      
    } catch (e) {
      log("Failed to update profile.");
    }
  }

Future<void> getMainUserInfor(BuildContext context) async {
  try {
    // get in4 user from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(globals.token).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      // get notifier from Provider
      final mainUser = Provider.of<ControlMainUser>(context, listen: false);
      // update in4 to notifier
      mainUser.updateUser(
        userData['name'] ?? 'Parent', 
        userData['phoneNumber'] ?? 'Parent', 
        userData['image'] ?? 'assets/img/avatar_mom.png', 
      );

            // decode image of user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userID = prefs.getString('token');
      String avatarUrl = 'https://huyln.info/parentlink/users/$userID/avatar';
      try {
        await AvatarManager.downloadAndSaveAvatar(
           avatarUrl, userID!);
    } catch (e) {
      print('Error save avatar of main user: $e');
    }


      log('User information saved to ControlMainUser');
    } else {
      log('User not found in Firestore');
    }
  } catch (e) {
    log('Error fetching user information: $e');
  }
}




  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    final ids = firestore
        .collection('users')
        .where('localId', whereIn: userIds)
        .snapshots();

    SharedPreferences.getInstance().then((prefs) async {
      final tasks = userIds.map((id) async {
        final avatarUrl =
            'https://huyln.info/parentlink/users/${me.id}/children-avatar/$id';
        final lastModified = prefs.getString('avatar_last_modified_$id') ??
            "1970-01-01T00:00:00Z";

        try {
          await AvatarManager.getOrUpdateAvatar(id, avatarUrl, lastModified);
        } catch (e) {
          log('Error updating avatar for $id: $e');
        }
      });

      // Run all avatar update tasks in parallel
      await Future.wait(tasks);
    });

    return ids;
  }

  static String getConversationID(String id) =>
      token.hashCode <= id.hashCode ? '${token}_$id' : '${id}_${token}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id!)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type,
      String userImage, String userName) async {
    //message sending time (also used as id)
    final time = Timestamp.now().microsecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: token,
        userImage: userImage,
        userName: userName,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id!)}/messages/');
    await ref.doc(time).set(message.toJson()).then(
          (value) =>
              sendPushNotification(chatUser, type == Type.text ? msg : 'image'),
        );
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId!)}/messages/')
        .doc(message.sent)
        .update({'read': Timestamp.now().microsecondsSinceEpoch.toString()});
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final userData = await firestore.collection('users').doc(token).get();
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id!)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(
        chatUser, imageUrl, Type.image, userData['image'], userData['name']);
  }

  // Add an chat user for conversation
  static Future<bool> addChatUserById(String userID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    String? role = sharedPreferences.getString('role');

    final data = await firestore
        .collection('users')
        .where('localId', isEqualTo: userID)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != token) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(token)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      if (role == 'children') {
        firestore
            .collection('users')
            .doc(userID)
            .collection('my_users')
            .doc(token)
            .set({});
      }

      return true;
    } else {
      print(
          "User not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not foundUser not found");

      return false;
    }
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    print(globals.token);
    return firestore
        .collection('users')
        .doc(globals.token)
        .collection('my_users')
        .snapshots();
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id!)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    final userData =
        await firestore.collection('users').doc(globals.token).get();
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(globals.token)
        .set({}).then((value) => sendMessage(
            chatUser, msg, type, userData['image'], userData['name']));
  }
}
