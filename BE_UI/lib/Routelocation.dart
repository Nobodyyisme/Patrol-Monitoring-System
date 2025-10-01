import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreeRoutingMap extends StatefulWidget {
  final String? patrolId;   // Optional
  final LatLng src;         // Required
  final LatLng? dest;       // Optional

  const FreeRoutingMap({
    Key? key,
    this.patrolId,
    required this.src,
    this.dest,
  }) : super(key: key);

  @override
  _FreeRoutingMapState createState() => _FreeRoutingMapState();
}



class _FreeRoutingMapState extends State<FreeRoutingMap> {
  String? petrolid;
  LatLng? origin;
  LatLng? destination;
  List<LatLng> routePoints = [];

  int currentIndex = 0;
  LatLng? currentUserLoc;
  Timer? movementTimer;

  List<LatLng> deviationPoints = [];
  bool isUserOnRoute = true;

  final MapController _mapController = MapController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  void startMarkerMovement() {
    if (routePoints.isEmpty) return;
    print("startMarkerMovement is called");
    currentIndex = 0;

    movementTimer?.cancel();

    movementTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (currentIndex < routePoints.length) {
        LatLng newLocation = routePoints[currentIndex];
        checkUserOnRoute(newLocation);
        currentIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  void checkUserOnRoute(LatLng userLocation) {
    final Distance distance = Distance();
    double minDistance = double.infinity;

    for (LatLng point in routePoints) {
      double currentDistance =
          distance.as(LengthUnit.Meter, userLocation, point);
      if (currentDistance < minDistance) {
        minDistance = currentDistance;
      }
    }

    bool currentlyOnRoute = minDistance <= 30;

    setState(() {
      currentUserLoc = userLocation;

      if (currentlyOnRoute) {
        // User is on the route
        isUserOnRoute = true;
      } else {
        // User has deviated from the route
        if (isUserOnRoute) {
          // First time leaving the route
          deviationPoints = [currentUserLoc!];
        } else {
          // Continuing on new route
          deviationPoints.add(currentUserLoc!);
        }
        isUserOnRoute = false;
      }
    });
  }

  void _handleTap(LatLng point) async {
    if (origin == null) {
      origin = point;
    } else if (destination == null) {
      destination = point;
      await getRoute();
      startMarkerMovement();
    } else {
      destination = point;
      await getRoute();
      startMarkerMovement();
    }
    setState(() {});
  }

  Future<void> getRoute() async {
    if (origin == null || destination == null) return;

    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${origin!.longitude},${origin!.latitude};${destination!.longitude},${destination!.latitude}?geometries=geojson&overview=full');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        routePoints =
            coords.map((point) => LatLng(point[1], point[0])).toList();
        deviationPoints.clear();
      });

      _mapController.fitBounds(
        LatLngBounds.fromPoints([origin!, destination!]),
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );

      print('Route Points Length: ${routePoints.length}');
    } else {
      print('Error fetching route');
    }
  }

  Future<LatLng?> _getCoordinates(String address) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');

    final response =
        await http.get(url, headers: {'User-Agent': 'Flutter App'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  Future<void> searchRouteByAddress() async {
    final startAddress = originController.text.trim();
    final endAddress = destinationController.text.trim();

    final startCoords = await _getCoordinates(startAddress);
    final endCoords = await _getCoordinates(endAddress);

    if (startCoords != null && endCoords != null) {
      setState(() {
        origin = startCoords;
        destination = endCoords;
      });
      await getRoute();
      startMarkerMovement();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One or both addresses not found')),
      );
    }
  }

  void _resetMap() {
    setState(() {
      origin = null;
      destination = null;
      routePoints.clear();
      deviationPoints.clear();
      originController.clear();
      destinationController.clear();
      currentUserLoc = null;
      currentIndex = 0;
      isUserOnRoute = true;
      movementTimer?.cancel();
    });
  }


  Future<bool> _requestLocationPermission() async {
    while (true) {
      var status = await Permission.location.request();

      if (status.isGranted) {
        return true; // Permission granted, proceed
      } else if (status.isPermanentlyDenied) {
        // Show alert to guide user to settings
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Permission Required"),
            content: Text(
                "Location permission is permanently denied. Please enable it from app settings."),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Open Settings"),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        return false; // Stop trying
      } else {
        // Show warning if denied but not permanently
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Permission Required"),
            content:
            Text("Location permission is required to get your location."),
            actions: [
              TextButton(
                child: Text("Try Again"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  String _locationMessage = 'Press the button to get your location!';

  // Function to get location
  Future<Map<String, double>> _getLocation() async {
    bool permissionGranted = await _requestLocationPermission();

    if (!permissionGranted) {
      setState(() {
        _locationMessage = 'Permission not granted.';
      });
      return {}; // empty map if permission denied
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _locationMessage =
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });

      return {
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
    } catch (e) {
      setState(() {
        _locationMessage = 'Failed to get location: $e';
      });
      return {}; // return empty map on error
    }
  }

  Future<void> sendLocationToAPI(String patrolId) async {
    // Step 1: Get user's current coordinates
    final location = await _getLocation();
    if (location.isEmpty) {
      print('Location not available.');
      return;
    }

    final double latitude = location['latitude']!;
    final double longitude = location['longitude']!;

    // Step 2: Get token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found in SharedPreferences.');
      return;
    }

    // Step 3: Build request URL
    final url = Uri.parse(
      'https://patrol-monitoring-system1.onrender.com/api/patrol/$patrolId/track'
          '?latitude=$latitude&longitude=$longitude',
    );

    // Step 4: Send the POST request
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Location sent successfully.');
      } else {
        print('Failed to send location. Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }



  @override
  void initState() {
    super.initState();
    origin = widget.src;
    petrolid = petrolid ?? "";
    destination = widget.dest ?? widget.src;
    originController.addListener(() => setState(() {}));
    destinationController.addListener(() => setState(() {}));
    if (petrolid != null){
      sendLocationToAPI(petrolid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(23.033863, 72.585022),
                zoom: 4.0,
                onTap: (tapPosition, point) => _handleTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.black,
                    ),
                    Polyline(
                      points: deviationPoints,
                      strokeWidth: 4.0,
                      color: Colors.red,
                    )
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (origin != null)
                      Marker(
                        point: origin!,
                        width: 40,
                        height: 40,
                        builder: (ctx) => const Icon(Icons.location_on,
                            color: Colors.green, size: 40),
                      ),
                    if (destination != null)
                      Marker(
                        point: destination!,
                        width: 40,
                        height: 40,
                        builder: (ctx) => const Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                      ),
                    if (currentUserLoc != null)
                      Marker(
                        point: currentUserLoc!,
                        width: 40,
                        height: 40,
                        builder: (ctx) => const Icon(Icons.location_on,
                            color: Colors.blue, size: 40),
                      ),
                  ],
                )
              ],
            ),
            Positioned(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.grey[200]?.withOpacity(0.9),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: originController,
                            decoration: InputDecoration(
                              labelText: 'Origin Address',
                              border: OutlineInputBorder(),
                              suffixIcon: originController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        originController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: destinationController,
                            decoration: InputDecoration(
                              labelText: 'Destination Address',
                              border: OutlineInputBorder(),
                              suffixIcon: destinationController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        destinationController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (originController.text.isNotEmpty &&
                      destinationController.text.isNotEmpty)
                    ElevatedButton(
                      onPressed: searchRouteByAddress,
                      child: const Text('Search Route by Address'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: () {
              _mapController.move(
                  _mapController.center, _mapController.zoom + 1);
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: () {
              _mapController.move(
                  _mapController.center, _mapController.zoom - 1);
            },
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: _resetMap,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
