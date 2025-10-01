// Your imports remain unchanged
import 'dart:convert';
import 'package:be_ui/Routelocation.dart';
import 'package:be_ui/dashboardbackground.dart';
import 'package:be_ui/showpatrol.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginatedPatrolsPage extends StatefulWidget {
  final String filterType;
  const PaginatedPatrolsPage({super.key, this.filterType = 'all'});

  @override
  State<PaginatedPatrolsPage> createState() => _PaginatedPatrolsPageState();
}

class _PaginatedPatrolsPageState extends State<PaginatedPatrolsPage> {
  int currentPage = 1;
  int totalPages = 1;
  final int limit = 7;
  String _sortOrder = 'newest';
  List<dynamic> patrols = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPatrols(widget.filterType);
  }

  Future<void> fetchPatrols(String filterType) async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('id');

    final url = Uri.parse(
        "https://patrol-monitoring-system1.onrender.com/api/patrol/officer/$id?page=$currentPage&limit=$limit");

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> fetched = jsonData['data'];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (filterType == 'today') {
        fetched = fetched.where((p) {
          final start = DateTime.tryParse(p['startTime'] ?? '');
          if (start == null) return false;
          final date = DateTime(start.year, start.month, start.day);
          return date == today;
        }).toList();
      } else if (filterType == 'active') {
        fetched = fetched.where((p) => p['status'] == 'in-progress').toList();
        print(fetched);
        print(fetched.length);
      } else if (filterType == 'completed') {
        fetched = fetched.where((p) => p['status'] == 'completed').toList();
      }

      fetched.sort((a, b) {
        final dateA = DateTime.tryParse(a['startTime'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['startTime'] ?? '') ?? DateTime.now();
        return _sortOrder == 'newest'
            ? dateB.compareTo(dateA)
            : dateA.compareTo(dateB);
      });

      setState(() {
        patrols = fetched;
        currentPage = jsonData['pagination']['currentPage'];
        totalPages = jsonData['pagination']['totalPages'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception("Failed to fetch patrols");
    }
  }

  Widget buildPatrolCard(Map<String, dynamic> patrol) {
    final title = patrol['title'] ?? '';
    final route = patrol['patrolRoute']?['name'] ?? 'Unknown';
    final priority = patrol['priority'] ?? '-';
    final status = patrol['status'] ?? '-';
    final officers = (patrol['assignedOfficers'] as List).map((o) => o['name']).join(', ');
    final checkpoints = patrol['patrolRoute']?['checkpoints'] ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => PatrolDetailPage(patrol: patrol),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧭 Title + Location Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                if (checkpoints.length >= 2)
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    onPressed: () {
                      final src = checkpoints.first['coordinates'];
                      final dest = checkpoints.last['coordinates'];

                      print("📍 Source: (${src['latitude']}, ${src['longitude']})");
                      print("🏁 Destination: (${dest['latitude']}, ${dest['longitude']})");

                      if (widget.filterType == 'active' && src != null && dest != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreeRoutingMap(
                              patrolId: patrol['_id'], // ✅ named parameter
                              src: LatLng(src['latitude'], src['longitude']), // ✅ required named
                              dest: LatLng(dest['latitude'], dest['longitude']), // ✅ optional named
                            ),
                          ),
                        );

                      }
                    },
                  )

              ],
            ),
            const SizedBox(height: 6),
            Text("Route: $route", style: const TextStyle(color: Colors.white70)),
            Text("Officers: $officers", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status: $status",
                    style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600)),
                Text("Priority: $priority",
                    style: TextStyle(
                        color: _getPriorityColor(priority),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
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
        return Colors.blueAccent;
      case 'scheduled':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: currentPage > 1
                  ? () {
                setState(() => currentPage--);
                fetchPatrols(widget.filterType);
              }
                  : null,
              child: const Text("Previous"),
            ),
          ),
          Flexible(
            child: Center(
              child: Text(
                "Page $currentPage of $totalPages",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: currentPage < totalPages
                  ? () {
                setState(() => currentPage++);
                fetchPatrols(widget.filterType);
              }
                  : null,
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Patrols",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            color: const Color(0xFF1B263B),
            onSelected: (value) {
              setState(() => _sortOrder = value);
              fetchPatrols(widget.filterType);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'newest',
                child: _buildSortItem("Newest to Oldest", Icons.arrow_upward),
              ),
              PopupMenuItem(
                value: 'oldest',
                child: _buildSortItem("Oldest to Newest", Icons.arrow_downward),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: DashboardBackground(
          child: isLoading
              ? const Center(
              child:
              CircularProgressIndicator(color: Colors.lightBlueAccent))
              : Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: Colors.lightBlueAccent,
                  backgroundColor: const Color(0xFF1B263B),
                  onRefresh: () => fetchPatrols(widget.filterType),
                  child: patrols.isEmpty
                      ? const Center(
                    child: Text(
                      "No Duties All Done",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      : ListView.builder(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    itemCount: patrols.length,
                    itemBuilder: (context, index) =>
                        buildPatrolCard(patrols[index]),
                  ),
                ),
              ),
              if (patrols.isNotEmpty) _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortItem(String label, IconData icon) {
    final selected = (_sortOrder == 'newest' && icon == Icons.arrow_upward) ||
        (_sortOrder == 'oldest' && icon == Icons.arrow_downward);
    return Row(
      children: [
        Icon(icon,
            color: selected ? Colors.lightBlueAccent : Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.lightBlueAccent : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
