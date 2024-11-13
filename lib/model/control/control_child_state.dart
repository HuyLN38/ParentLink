import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parent_link/model/child/child_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlChildState extends ChangeNotifier {
  List<ChildState> listChild = [];

  List<ChildState> get getlistChild => listChild;

  Future<void> fetchChildrenData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
          Uri.parse('https://huyln.info/parentlink/users/$token/children'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['children'] == null) {
          return;
        }

        final List<ChildState> fetchedChildren = [];

        for (var child in data['children']) {
          if (child == null) continue;

          // Use the factory constructor for safe creation
          final childState = ChildState.fromJson(child);
          print('Fetched child: $childState.childId');

          // Only update avatar if we have a valid childId
          if (childState.childId != null) {
            print(
                "https://huyln.info/parentlink/users/$token/children-avatar/${childState.childId}");
            await childState.updateAvatar(
                'https://huyln.info/parentlink/users/$token/children-avatar/${childState.childId}');
          } else {
            print('No childId found for ${childState.name}');
          }

          fetchedChildren.add(childState);
        }

        listChild = fetchedChildren;
        notifyListeners();
      } else {
        throw Exception('Failed to load children data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching children data: $e');
      rethrow;
    }
  }
}
