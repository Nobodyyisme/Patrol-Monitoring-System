import 'package:be_ui/dashboardbackground.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatrolDetailPage extends StatelessWidget {
  final Map<String, dynamic> patrol;

  const PatrolDetailPage({super.key, required this.patrol});

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  @override
  Widget build(BuildContext context) {
    final route = patrol['patrolRoute'];
    final checkpoints = route?['checkpoints'] ?? [];
    final source = checkpoints.isNotEmpty ? checkpoints.first['name'] : 'N/A';
    final destination = checkpoints.isNotEmpty ? checkpoints.last['name'] : 'N/A';
    final incidents = checkpoints
        .where((c) => c['name']?.toString().toLowerCase().contains('incident') ?? false)
        .map((c) => c['description'])
        .toSet()
        .toList();

    final officers = (patrol['assignedOfficers'] as List)
        .map((o) => o['name'])
        .join(', ');

    final start = DateTime.parse(patrol['startTime']).toLocal();
    final end = DateTime.parse(patrol['endTime']).toLocal();
    final status = patrol['status'];
    final priority = patrol['priority'];
    final distance = patrol['totalDistance'];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        title: Text(patrol['title'] ?? 'Patrol Detail',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: DashboardBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInlineTile("Source", source, "Destination", destination),
            _buildInfoTile("Officers", officers),
            _buildInfoTile("Status", status),
            _buildInfoTile("Priority", priority),
            _buildInfoTile("Start Time", "${_formatDate(start)} at ${_formatTime(start)}"),
            _buildInfoTile("End Time", "${_formatDate(end)} at ${_formatTime(end)}"),
            _buildInfoTile("Total Distance", "$distance km"),
            _buildInfoTile("Incidents", incidents.isNotEmpty ? incidents.join('\n\n') : "None"),
          ],
        ),
      ),
    );
  }

}


Widget _buildInfoTile(String label, String value) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    color: const Color(0xFF1B263B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E4C6D), // inner box background
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInlineTile(String label1, String value1, String label2, String value2) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    color: const Color(0xFF1B263B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E4C6D), // light navy blue
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label1,
                      style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(value1,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3E5C76), // different blue shade
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label2,
                      style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(value2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
