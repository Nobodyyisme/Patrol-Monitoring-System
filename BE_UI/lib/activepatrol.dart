import 'dart:convert';
import 'package:be_ui/showpatrol.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaginatedPatrolsPage extends StatefulWidget {
  final String filterType; // ✅ "today", "active", "all"
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
      "https://patrol-monitoring-system1.onrender.com/api/patrol/officer/$id?page=$currentPage&limit=$limit",
    );

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> fetched = jsonData['data'];

      // ✅ Apply filtering based on filterType
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
      }

      // ✅ Sort based on selected order
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
    final officers =
        (patrol['assignedOfficers'] as List).map((o) => o['name']).join(', ');

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
        padding: const EdgeInsets.all(20),
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text("Route: $route",
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            Text("Officers: $officers",
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const Spacer(),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward,
                        color: _sortOrder == 'newest'
                            ? Colors.lightBlueAccent
                            : Colors.white,
                        size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "Newest to Oldest",
                      style: TextStyle(
                        color: _sortOrder == 'newest'
                            ? Colors.lightBlueAccent
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'oldest',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_downward,
                        color: _sortOrder == 'oldest'
                            ? Colors.lightBlueAccent
                            : Colors.white,
                        size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "Oldest to Newest",
                      style: TextStyle(
                        color: _sortOrder == 'oldest'
                            ? Colors.lightBlueAccent
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.lightBlueAccent))
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < -50 &&
                    currentPage < totalPages) {
                  setState(() => currentPage++);
                  fetchPatrols(widget.filterType);
                } else if (details.primaryVelocity! > 50 && currentPage > 1) {
                  setState(() => currentPage--);
                  fetchPatrols(widget.filterType);
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.lightBlueAccent,
                      backgroundColor: const Color(0xFF1B263B),
                      onRefresh: () => fetchPatrols(widget.filterType),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: patrols.length,
                        itemBuilder: (context, index) =>
                            buildPatrolCard(patrols[index]),
                      ),
                    ),
                  ),
                  _buildPaginationControls(),
                ],
              ),
            ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: currentPage > 1
                ? () {
                    setState(() => currentPage--);
                    fetchPatrols(widget.filterType);
                  }
                : null,
            child: const Text("Previous"),
          ),
          Text("Page $currentPage of $totalPages",
              style: const TextStyle(color: Colors.white70)),
          ElevatedButton(
            onPressed: currentPage < totalPages
                ? () {
                    setState(() => currentPage++);
                    fetchPatrols(widget.filterType);
                  }
                : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }
}
