import 'package:flutter/material.dart';

import '../model/Child.dart';
import 'ChildrenService.dart';


class ChildrenProvider with ChangeNotifier {
  final ChildrenService _childrenService;
  List<Child> _children = [];

  List<Child> get children => _children;

  ChildrenProvider(BuildContext context) : _childrenService = ChildrenService(context);

  Future<void> fetchChildren(String parentId) async {
    try {
      _children = await _childrenService.fetchChildren(parentId);
      notifyListeners();
    } catch (e) {
      print('Error fetching children: $e');
    }
  }
}