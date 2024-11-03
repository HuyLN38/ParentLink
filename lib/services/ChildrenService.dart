import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../model/Child.dart';
import 'ChildrenProvider.dart';

class ChildrenService {
  final BuildContext context;
  ChildrenService(this.context);

  Future<List<Child>> fetchChildren(String parentId) async {
    final url = Uri.parse('https://huyln.info/parentlink/users/$parentId/children');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> childrenJson = data['children'];
      return childrenJson.map((json) => Child.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load children');
    }
  }
}