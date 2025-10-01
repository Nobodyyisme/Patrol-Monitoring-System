import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class UserLocationMap extends StatefulWidget {
  @override
  _UserLocationMapState createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<UserLocationMap> {
  String _locationMessage = 'Press the button to get your location!';

  // Function to request permission every time
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
            content: const Text(
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

  // Function to get location
  Future<void> _getLocation() async {
    bool permissionGranted = await _requestLocationPermission();

    if (!permissionGranted) {
      setState(() {
        _locationMessage = 'Permission not granted.';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationMessage =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });

      // Send location to API
    } catch (e) {
      setState(() {
        _locationMessage = 'Failed to get location: $e';
      });
    }
  }

  // Function to send location to Flask API
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text('Location Sender'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Your Current Location:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _locationMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getLocation,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get Location',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
