import 'package:flutter/material.dart';

class AlertPage extends StatelessWidget {
  final List<Map<String, dynamic>> alerts = [
    {
      'title': 'Intrusion Detected',
      'subtitle': 'Motion detected at Sector 3',
      'time': '2 min ago',
      'icon': Icons.warning,
      'color': Colors.deepOrange,
    },
    {
      'title': 'System Check',
      'subtitle': 'Routine system diagnostics completed',
      'time': '10 min ago',
      'icon': Icons.check_circle,
      'color': Colors.blue,
    },
    {
      'title': 'Camera Offline',
      'subtitle': 'Camera 12 went offline',
      'time': '30 min ago',
      'icon': Icons.videocam_off,
      'color': Colors.redAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: alert['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: alert['color'],
                  child: Icon(alert['icon'], color: Colors.white),
                ),
                title: Text(alert['title'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(alert['subtitle']),
                trailing: Text(
                  alert['time'],
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Create new alert (future feature)')),
          );
        },
        child: Icon(Icons.add_alert),
      ),
    );
  }
}
