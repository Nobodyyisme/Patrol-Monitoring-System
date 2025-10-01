import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  final List<Map<String, dynamic>> reports = [
    {
      'title': 'Unauthorized Entry',
      'location': 'Gate 3',
      'time': 'Today • 02:15 AM',
      'status': 'Unresolved',
    },
    {
      'title': 'Loitering Detected',
      'location': 'Zone B - Hallway',
      'time': 'Yesterday • 11:48 PM',
      'status': 'Resolved',
    },
    {
      'title': 'Abnormal Vehicle Stop',
      'location': 'Checkpoint 5',
      'time': 'Yesterday • 09:20 PM',
      'status': 'Unresolved',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Reports'),
        backgroundColor: Color(0xFF1976D2),
        actions: [
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportCard(report, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: _dropdown('Zone', ['All', 'Zone A', 'Zone B', 'Gate 3'])),
          SizedBox(width: 10),
          Expanded(
              child: _dropdown('Date', ['Today', 'Yesterday', 'Last 7 Days'])),
        ],
      ),
    );
  }

  Widget _dropdown(String hint, List<String> items) {
    String? selectedItem = items.first;
    return DropdownButtonFormField<String>(
      value: selectedItem,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, BuildContext context) {
    Color statusColor =
        report['status'] == 'Resolved' ? Colors.green : Colors.redAccent;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: statusColor, width: 5),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.report_problem, color: statusColor),
        title: Text(
          report['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${report['location']} • ${report['time']}'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            report['status'],
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
