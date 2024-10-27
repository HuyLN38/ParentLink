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
          "project_id": "parentlink-30210",
          "private_key_id": "669d6bc0d9e8446250c9bfe55293366547e43618",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCTiBz6EKvgtSYB\nV9JohWF8qOT7WW0xtIvvGqFoNdgrklxBbKlwgWO5p01NR7uK5yJJujmSBICLw5Aq\nU8hX5DOg0U08UEIxZR8MqiK1BQYysP7U2V1C6flr8w3dZPQx/xwdkUS/WeVPPPIp\ntvH/GjDlcVroKxwUiONcsvefvhzmeM/3Xd+FsYM1Nnyr2fQyFqFVxNTYnsClWn6J\nWqI7CKYo/35seMrGTC0i3aKefNip7yWFG+CaufHxchzF53Wg+52XVIBLdNHX08cf\niQkuLEiG92bw9Zivsuz8+4YNvGNlk2gA7C+RqjqoyqrxM0lCDjdmPE4pbLJVorWe\nDo9I1D+hAgMBAAECggEAAtZo3ERq0eEaEIeMY/dAx0GGWfE/4Odck6Y6+YKjnD7t\n6FI7Ng8/CEiX+4cIK+VDKxDaX50XjdiekrnWzh31AkBUUHcotsN/o+I31ax5kIsH\n87cUjJ9sbS+ZEiuJaNbDxyvOmzGS8AG3lKbQo7vwudEC0xlVKm3xlYxZp+hjrOkZ\neMkJvNIYMf/FPYFxylx1VAf2/3sGnN88DYwoIcCYOtiv6FH8eMovJbroOrIdMSTw\ndNCgKnM4s4EkUC3JGxfRe97b/8MMSgvWaaoHfTwwdUmLjc2My24chm4wQrb+m1KD\nf8a1UU1Yj3KfmDicTcicZrdnFs+9bpHNmwJP3vu8WQKBgQC+38Q19k2inAPGbBF5\nM44/zA4xEbjbLlU+sXItZiEQWUTNZEUQZyyEPxIwiVST+UwbcF37eNqoMKN3iiQ8\njAiQI/SkLEWUqzfsK5a2C5Ly8N3LI7kVJLE14HK3KpmUGB/lZlvx9QU7m4PCqgLI\nwuoii6L2qKh/LDCpWlI9Xs/JNQKBgQDF3odhFZFd/W6Tdsi5ljGFFN/2pn/smA3l\naMXk20GPOQzknc1pLfF39inkgVYwu/vFYjSbfs+EgMNPKHLXaxOiLb67MioMt5nV\nKhU5y9dxHD4yoT7UYOI+qxAhqu28p7O5YVmw3Zn0ommGuRViQdLoaU/2e2tL+mGp\nzVk8BYPWPQKBgQCdYjiRHhQJnobmVzlZLI+APyr8ftZjs6KKXRn+IRXmOxUmHiVs\nTwY/zRmcd8ALeyWsAk0cCxyQTfqbmIYkfnqZD2yq6e49lag4zgAo/wYd10mqNDxq\nGKUd/YHZUgDsQbAbIPlzWksESUitfC1riHwyG901cP/uTGubWGQzQjgmeQKBgQCR\nRlmVIRWysWCfKkYjZC+Faxcoa4RevCDvvyYUahpPQm7B504qHA4+qmCFoaQbcdlf\nSUQgqlFIEpXTJ3pxyO8IUpfHrwQKhD6QsC4XWh8ar8bGu3Z6zYsuwb+9SFb1/RbK\nU7xbS8g+QYRC4t7dXkCwXKnV6TWU+gb8eYU7uTzbbQKBgDFtudlVRUIqdvjkqY78\nYJpY+o8xPks9laZTs04Dd7prvM78HP3OjXdoYnMbRRSjcqsxWecubtGehRlZYk12\n/YksoRA7oNCS0cyyzb/5KvPW8qS7/MFU1Si3Y77CCabWe13Dg3A9AAe7+YMyv4Ql\nOjCCFOwITkmQ2gWDToDK8U8W\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-pfvba@parentlink-30210.iam.gserviceaccount.com",
          "client_id": "102377026620332820765",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-pfvba%40parentlink-30210.iam.gserviceaccount.com",
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
