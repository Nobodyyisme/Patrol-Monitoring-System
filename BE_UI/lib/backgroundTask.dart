import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:be_ui/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == "checkActivePatrols") {
      const String apiUrl =
          "https://patrol-monitoring-system1.onrender.com/api/patrol/officer/"; // Add proper ID

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final id = prefs.getString('id');

      if (token == null || id == null) return Future.value(true);

      final url = Uri.parse("$apiUrl$id?page=1&limit=7");
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patrols = data['data'] as List<dynamic>;

        final active = patrols.where(
              (p) => p['status']?.toString().toLowerCase() == 'in-progress',
        );

        if (active.isNotEmpty) {
          await flutterLocalNotificationsPlugin.show(
            1,
            "Active Patrol Detected",
            "${active.length} patrol(s) are in progress.",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'active_patrols',
                'Active Patrol Alerts',
                channelDescription: 'Triggered when active patrols are found',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      }

      return Future.value(true);
    }

    return Future.value(false);
  });
}
