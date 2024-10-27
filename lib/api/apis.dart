import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:parent_link/api/notification_access_token.dart';
import 'package:parent_link/model/chat_user.dart';
import 'package:parent_link/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();

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

      const projectID = 'flutter-chat-app-d0ca7';
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

  static User get user => auth.currentUser!;

  static late ChatUser me;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then(
      (user) {
        if (user.exists) {
          me = ChatUser.fromJson(user.data()!);
          getFirebaseMessagingToken();
        } else {}
      },
    );
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('localId', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> createUser(User userCurrent, String username,
      String useremail, String imageURL) async {
    final time = Timestamp.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        name: username,
        email: useremail,
        about: "I'm using Chat Web",
        createdAt: time,
        image: imageURL,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(userCurrent.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('localId', whereIn: userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

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
        fromId: user.uid,
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
    final userData = await firestore.collection('users').doc(user.uid).get();
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
    final data = await firestore
        .collection('users')
        .where('localId', isEqualTo: userID)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
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
    final userData = await firestore.collection('users').doc(user.uid).get();
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(
            chatUser, msg, type, userData['image'], userData['name']));
  }
}
