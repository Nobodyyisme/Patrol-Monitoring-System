import 'package:be_ui/alert.dart';
import 'package:be_ui/reports.dart';
import 'package:flutter/material.dart';

class PatrolDashboardScreen extends StatelessWidget {
  const PatrolDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text(
          'AI Patrol Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.lightBlueAccent),
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.lightBlueAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildStatusCards(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildRecentDetections(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return const ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(Icons.security, color: Colors.white),
      ),
      title: Text(
        'Welcome, Officer John',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        'Shift: Night Patrol • Zone A',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Text(
        'Online',
        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusCard('Anomalies', '3', Icons.warning_amber, Colors.redAccent),
        _buildStatusCard('Routes', '5', Icons.route, Colors.lightBlueAccent),
        _buildStatusCard('AI Status', 'Normal', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatusCard(String title, String data, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              data,
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton('Live Feed', icon: Icons.videocam, color: Colors.deepOrange, onPressed: () {}),
            _actionButton('Reports', icon: Icons.receipt_long, color: Colors.lightBlue, onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsPage()));
            }),
            _actionButton('Alerts', icon: Icons.notifications, color: Colors.redAccent, onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AlertPage()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
      String label, {
        required IconData icon,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRecentDetections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent AI Detections',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _detectionItem('Unusual movement at Gate 3', '5 mins ago'),
        _detectionItem('Loitering near restricted area', '20 mins ago'),
        _detectionItem('Vehicle stopped in patrol path', '1 hr ago'),
      ],
    );
  }

  Widget _detectionItem(String title, String time) {
    return Card(
      color: const Color(0xFF1B263B),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.visibility, color: Colors.amber),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

}
