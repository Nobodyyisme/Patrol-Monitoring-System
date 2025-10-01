import 'dart:convert';
import 'package:be_ui/Routelocation.dart';
import 'package:be_ui/showincident.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncidentListPage extends StatefulWidget {
  const IncidentListPage({Key? key}) : super(key: key);

  @override
  State<IncidentListPage> createState() => _IncidentListPageState();
}

class _IncidentListPageState extends State<IncidentListPage> {
  List<dynamic> incidents = [];
  List<dynamic> allIncidents = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchIncidents();
  }

  Future<void> fetchIncidents() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(
            'https://patrol-monitoring-system1.onrender.com/api/incidents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final list = jsonBody['data'] as List<dynamic>? ?? [];

        setState(() {
          allIncidents = list;
          incidents = list;
        });
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.deepPurpleAccent;
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text('Incidents',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    incidents = allIncidents
                        .where((incident) =>
                            (incident['title']?.toString().toLowerCase() ?? '')
                                .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search incidents by title...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1B263B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.lightBlueAccent))
                  : hasError
                      ? const Center(
                          child: Text('Error loading incidents',
                              style: TextStyle(color: Colors.white70)),
                        )
                      : incidents.isEmpty
                          ? const Center(
                              child: Text('No incidents found',
                                  style: TextStyle(color: Colors.white70)),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchIncidents,
                              color: Colors.lightBlueAccent,
                              backgroundColor: const Color(0xFF1B263B),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: incidents.length,
                                itemBuilder: (context, idx) {
                                  final inc = incidents[idx];
                                  final title = inc['title'] ?? '';
                                  final area = inc['area'] ?? '';
                                  final date = inc['date'];
                                  final time = inc['time'] ?? '';
                                  final reportedBy =
                                      inc['reportedBy']?['name'] ?? '';
                                  final severity = inc['severity'] ?? '';
                                  final formattedDate = date != null
                                      ? DateFormat('dd MMM yyyy')
                                          .format(DateTime.parse(date))
                                      : '';
                                  final coords = inc['coordinates'];
                                  LatLng? position;
                                  if (coords != null && coords['latitude'] != null && coords['longitude'] != null) {
                                    position = LatLng(coords['latitude'], coords['longitude']);
                                  }

                                  return InkWell(
                                    onTap: () {

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => IncidentDetailPage(incident: inc), // no `const`
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: const Color(0xFF1B263B),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.report,
                                                    color: _severityColor(
                                                        severity)),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _severityColor(severity)
                                                            .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    severity.toUpperCase(),
                                                    style: TextStyle(
                                                      color: _severityColor(
                                                          severity),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.place,
                                                    size: 18,
                                                    color:
                                                        Colors.lightBlueAccent),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text("📍 $area",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.white70)),
                                                ),
                                              ],
                                            ),
                                            Text("📅 $formattedDate at $time",
                                                style: const TextStyle(
                                                    color: Colors.white70)),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("🧍 Reported by: $reportedBy",
                                                    style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 13)),
                                                GestureDetector(
                                                    onTap: (){ if (position != null) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FreeRoutingMap(src: position!), // no `const`
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('No coordinates available for this incident.')),
                                                      );
                                                    }},
                                                    child: const Icon(Icons.location_pin , color: Colors.white))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIncidentForm(context),
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _submitIncident(
    String title,
    String description,
    String area,
    String locationName,
    String severity,
    String time,
    String witnessName,
    String witnessContact,
    String witnessStatement,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final Map<String, dynamic> incidentData = {
        "title": title,
        "description": description,
        "area": area,
        "locationName": locationName,
        "severity": severity,
        "time": time,
        "date": DateTime.now().toIso8601String(), // added date
        "witnesses": [
          {
            "name": witnessName,
            "contact": witnessContact,
            "statement": witnessStatement,
          }
        ]
      };

      final response = await http.post(
        Uri.parse(
            "https://patrol-monitoring-system1.onrender.com/api/incidents"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(incidentData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incident submitted successfully")),
        );
        fetchIncidents();
      } else {
        final body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed: ${body['message'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showIncidentForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final areaController = TextEditingController();
    final locationNameController = TextEditingController();
    final timeController = TextEditingController();
    final severityController = TextEditingController();
    final witnessNameController = TextEditingController();
    final witnessContactController = TextEditingController();
    final witnessStatementController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Create New Incident",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildTextField(controller: titleController, label: "Title"),
                _buildTextField(
                    controller: descriptionController, label: "Description"),
                _buildTextField(controller: areaController, label: "Area"),
                _buildTextField(
                    controller: locationNameController, label: "Location Name"),
                _buildTextField(
                    controller: severityController,
                    label: "Severity (low/medium/high/critical)"),
                _buildTextField(
                    controller: timeController, label: "Time (e.g. 14:30)"),
                const Divider(color: Colors.white54),
                const Text("Witness Info",
                    style: TextStyle(color: Colors.white70)),
                _buildTextField(
                    controller: witnessNameController, label: "Witness Name"),
                _buildTextField(
                    controller: witnessContactController,
                    label: "Witness Contact"),
                _buildTextField(
                    controller: witnessStatementController,
                    label: "Witness Statement"),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent),
                  icon: const Icon(Icons.send),
                  label: const Text("Submit"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _submitIncident(
                        titleController.text,
                        descriptionController.text,
                        areaController.text,
                        locationNameController.text,
                        severityController.text,
                        timeController.text,
                        witnessNameController.text,
                        witnessContactController.text,
                        witnessStatementController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF0D1B2A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
