import 'dart:convert';
import 'package:be_ui/alert.dart';
import 'package:be_ui/dashboard.dart';
import 'package:be_ui/dashboardbackground.dart';
import 'package:be_ui/incident.dart';
import 'package:be_ui/reports.dart';
import 'package:be_ui/showpatrol.dart';
import 'package:be_ui/totalpatrol.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PatrolDashboard extends StatefulWidget {
  const PatrolDashboard({super.key});

  @override
  State<PatrolDashboard> createState() => _PatrolDashboardState();
}

class _PatrolDashboardState extends State<PatrolDashboard> {
  late Future<Map<String, dynamic>> dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardData = fetchDashboardData();
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    final url = Uri.parse(
        "https://patrol-monitoring-system1.onrender.com/api/patrol/dashboard-stats");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody['success'] == true) {
        return jsonBody['data'];
      } else {
        throw Exception("API success is false");
      }
    } else {
      throw Exception("Failed to fetch dashboard data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_police_outlined,
                color: Colors.lightBlueAccent, size: 25),
            SizedBox(width: 8),
            Text(
              "AI Patrol Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: Colors.lightBlueAccent,
        backgroundColor: const Color(0xFF1B263B),
        onRefresh: () async {
          setState(() {
            dashboardData = fetchDashboardData();
          });
          await dashboardData;
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                  CircularProgressIndicator(color: Colors.lightBlueAccent));
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            } else {
              final stats = snapshot.data!;
              final recentPatrols = stats['recentPatrols'] as List<dynamic>;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildStatsRow(stats),
                    const SizedBox(height: 20),
                    const Text(
                      'Recent Patrols',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...recentPatrols
                        .map((patrol) => _buildPatrolCard(patrol))
                        .toList(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 48) / 2;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard(
            title: "Today",
            value: stats['patrolsToday'].toString(),
            icon: Icons.calendar_today,
            color: Colors.orangeAccent,
            width: cardWidth,
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  child: const PaginatedPatrolsPage(filterType: "today"),
                ),
              );
            }),
        _statCard(
            title: "Completed",
            value: stats['completedPatrols'].toString(),
            icon: Icons.check_circle,
            color: Colors.teal,
            width: cardWidth,
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  child: const PaginatedPatrolsPage(filterType: "completed"),
                ),
              );
            }),
        _statCard(
            title: "Total",
            value: stats['totalPatrols'].toString(),
            icon: Icons.timeline,
            color: Colors.amber,
            width: cardWidth,
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  child: const PaginatedPatrolsPage(filterType: "total"),
                ),
              );
            }),
        _statCard(
            title: "Active",
            value: stats['activePatrols'].toString(),
            icon: Icons.play_arrow,
            color: Colors.green,
            width: cardWidth,
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  child: const PaginatedPatrolsPage(filterType: "active"),
                ),
              );
            }),
        _statCard(
          title: "Locations",
          value: stats['totalLocations'].toString(),
          icon: Icons.location_pin,
          color: Colors.purple,
          width: cardWidth,
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.lightBlueAccent.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B263B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatrolCard(dynamic patrol) {
    final route = patrol['patrolRoute']?['name'] ?? 'Unknown';
    final startTime = DateTime.parse(patrol['startTime']).toLocal();
    final endTime = DateTime.parse(patrol['endTime']).toLocal();
    final assignedOfficers = patrol['assignedOfficers'] as List<dynamic>;
    final officer = assignedOfficers.isNotEmpty
        ? assignedOfficers.map((o) => o['name']).join(', ')
        : "Unassigned";

    return Card(
      color: const Color(0xFF1B263B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: const Icon(Icons.security, color: Colors.grey),
        title: Text(
          patrol['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Route: $route',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Start: ${_formatTime(startTime)} | End: ${_formatTime(endTime)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${patrol['status']}',
                  style: TextStyle(color: _getStatusColor(patrol['status'])),
                ),
                Text(
                  'Priority: ${patrol['priority']}',
                  style:
                  TextStyle(color: _getPriorityColor(patrol['priority'])),
                ),
              ],
            ),
          ],
        ),
        trailing:
        const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PatrolDetailPage(patrol: patrol)),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return const Color(0xFF90EE90);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.greenAccent;
      case 'in-progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.amberAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
