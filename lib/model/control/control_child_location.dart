import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:parent_link/model/child/child_location.dart';

class ControlChildLocation extends ChangeNotifier {
  List<ChildLocation> childLocationList = [
          ChildLocation("", "")
  ];
  List<ChildLocation> get getChildLocationList => childLocationList;

  Future<void> fetchChildLocations(String childId) async {
    final url = 'https://huyln.info/parentlink/users/children-location/$childId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<ChildLocation> locations = [
        ];

        if (data.containsKey('logs') && data['logs'] is List) {
          for (final log in data['logs']) {
            // Extract location and start time from the log
            final location = log['location'] ?? 'Unknown';
            final startDateTime = log['start'] != null
                ? _formatDateTime(log['start'])
                : 'Unknown';

            // Create a ChildLocation object and add it to the list
            locations.add(ChildLocation(location, startDateTime));
          }
        }

        // Reverse the entire locations list
        childLocationList = locations.reversed.toList();

        // Notify listeners to refresh the UI
        notifyListeners();
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching child locations: $e');
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour}:${dateTime.minute} ${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return 'Invalid DateTime';
    }
  }
}
