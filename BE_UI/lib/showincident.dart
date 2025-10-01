import 'dart:ui';
import 'package:flutter/material.dart';

class IncidentDetailPage extends StatelessWidget {
  final Map<String, dynamic> incident;
  const IncidentDetailPage({super.key, required this.incident});

  String _formatValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return "-";
    return value.toString();
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              _formatValue(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items, List<String> fields) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields.map((f) => _buildInfoRow(f, item[f])).toList(),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = incident['coordinates'] ?? {};

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Incident Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 🌈 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D1B2A), // Dark navy
                  Color(0xFF1B263B),
                  Color(0xFF26354B),
                  // Steel blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🌫️ Glassmorphism overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),

          // 📜 Scrollable Incident content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 32, 16, 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Title", incident['title']),
                  _buildInfoRow("Report Number", incident['reportNumber']),
                  _buildInfoRow("Area", incident['area']),
                  _buildInfoRow("Category", incident['category']),
                  _buildInfoRow("Severity", incident['severity']),
                  _buildInfoRow("Status", incident['status']),
                  _buildInfoRow("Date", incident['date']),
                  _buildInfoRow("Time", incident['time']),
                  _buildInfoRow("Description", incident['description']),
                  _buildInfoRow("Latitude", coordinates['latitude']),
                  _buildInfoRow("Longitude", coordinates['longitude']),
                  _buildInfoRow("Reported By", incident['reportedBy']?['name']),
                  _buildSection("Assigned Officers", incident['assignedTo'], ['name', 'badgeNumber']),
                  _buildSection("Witnesses", incident['witnesses'], ['name', 'contact', 'statement']),
                  _buildSection("Involved Persons", incident['involvedPersons'], ['name', 'description', 'role']),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
