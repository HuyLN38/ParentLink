import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "flutter-chat-app-d0ca7",
          "private_key_id": "cc5a46782558d66389f826a8c73c064b66c5bcc9",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCp6e3YkXT0rkEd\nYsCHw/F2lAI3WTc02Gow8fAKZjd33iSPyEjjBFqOxvsSFUUEVJHxUcfei3JvC/1A\nMPT2L88JNUZyHhlslZfru4nIbBT5pOxhQEuBp7lEmHoHRoea8+MBGn+jq436P8Ot\n+rdKa6H7Ph0S5L1XkNe4vv/HFr+e1M4fsipFVMJ51iyF+kjcVnjpBNeYUtQfnLeV\ndtA90ro9s/soGkHKOP9wjB4qrERuXkDtS8JU4he92mmEui6SwISYzZ+oqp9VFBNt\n+a0re6zWmIyjuDkWPVIMn0i0ynflQszRuoiby6BWaUkygyQvSzonK/kH5Z+nxgEG\nH8AOo27dAgMBAAECggEAARelP88vlqMdfWLfz1T4fcVV06VEhZfJQadMiRnpzAt8\nO1sTnOIE8wYJzIP2faCi5OTxtAHm1RqZS4sFCCV730NIa1NmNnHVGDQ3Ho1oqnI0\n/YBm+95oLS4NxXOJS6W7FTa7u1b5rVzblTLCGuhg54yZWJW/4eA8gs43jBV0BewK\n9rF+cyqunXANE5YNP1EdjGltOHw7EU6b5WXGJ3RcNxZ6Kulm4WQvy1s2aybsHQ/V\nX96AtxVZtQkmymZ8CzwpIVC48Lfr0AihFMGNndkNO91q7LeZk2h9fn0xRRTGXYvj\nLLlO22YlVvfkuVn5cWnlxTI/ooPwRSPeAW+iRYayAQKBgQDhE0bHWO19+Nx7MISr\nhtkwR1qTMp0CenqzDh7G7RC06MTKW91ILgtYC/aHMDMxiUIWgC7gmFYMVZ6iRN6K\nTd/gKVg73d2DfZ7pxH0u1FBi9889eWYgA+/MMWv64lcW40AHQ0WccYQ00ql/XFLS\nljeYO/pfCafUsz9FntENLOxfSQKBgQDBQmuAfyidi4Hi+NMVNhRAaZQ2RgsnZOyg\n4RA1ID4rvjwzMcP8xg/E1cuZl6IGwK+/q5EvWuMO0W7r+jjw/xUUJWvrBJteTKhV\nYJg3ac0Py1o/STEcGsTflyM/eoZZHc58Rg/pTiAVxj2Lgrn2bOufOpMfMyioRkQC\ntoOI3ERO9QKBgQDRP/ugn9OEN1a8DNp7IY5QLTZO/VItmLL0Pt9sL8BFgNZcD9YF\nIhGX1N9oxe4CUsqnYpqyYc41/2/RCtgemtHVdHq8hcNIWQTh7rQ3Ulo9+Ieqbm/8\nucw5+YSbJcyz0aiYV/mivYKdHXFJoAq8D742AST/MFnhDJh5YHKYnjhPSQKBgQC2\nvywQsi2h7I3CJzDTWfQEhNHWEJ3zfogUCT7ePcMMcjNS5bhCirfWlaSVdMGOSR7n\nzEDZ2sPi+0A8fLzjhxJTnp9R+WVB4pM7SMAnhjCWwuBv/7IktVt9Ytm96QqpsnnT\nIh1hrLLCZFdGWTOoRo74XtdIJYRIu0kMl7IB9OfTEQKBgDE5mL0gYMSdJaFEyQqH\nwmRFh+ZFE5Munjv/czAm4fTvJWGaYuW9Xxu7wSfrRvEVkS5WzmgN/LnC5RyNDZfk\nxSx08n2E4YtPrSCfRzczsYRx/TEjaqTwpZ20me2d7mBaopXVYlTJ1uDv7y2Dils0\nG75yMKH+8yV8VGmFlFL3xD1N\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-iceuh@flutter-chat-app-d0ca7.iam.gserviceaccount.com",
          "client_id": "110956014289840854527",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-iceuh%40flutter-chat-app-d0ca7.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
