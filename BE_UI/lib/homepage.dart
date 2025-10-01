import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:be_ui/aboutus.dart';
import 'package:be_ui/dashboard.dart';
import 'package:be_ui/incident.dart';
import 'package:be_ui/patroldashboard.dart';
import 'package:be_ui/model/user.dart';
import 'package:be_ui/onboard.dart';
import 'package:be_ui/profilescreen.dart';
import 'package:be_ui/provider/userprovider.dart';
import 'package:be_ui/reports.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class U_homepage extends StatefulWidget {
  const U_homepage({Key? key}) : super(key: key);

  @override
  State<U_homepage> createState() => _U_homepageState();
}

class _U_homepageState extends State<U_homepage> {
  double value = 0;
  String userName = "";

  profiledata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    print(token);

    try {
      final profileurl = Uri.parse(
          "https://patrol-monitoring-system1.onrender.com/api/auth/me");

      // Get the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs
          .getString('token'); // Make sure you stored the token during login

      final response = await http.get(
        profileurl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Send JWT in header
        },
      );

      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final profiledata = jsonDecode(response.body);
        User user = User.fromJson(profiledata['user']);
        context.read<UserProvider>().setUser(user);
      } else {
        print("Request failed: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> logoutUser(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("No token found.");
      return;
    }

    try {
      final logoutUrl = Uri.parse(
          "https://patrol-monitoring-system1.onrender.com/api/auth/logout");

      final response = await http.post(
        logoutUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Logout successful.');
        // Optional: Clear token
        await prefs.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Error during logout: $e',
              style: TextStyle(
                fontSize: 18, // Make the text bigger
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white, // Text color
              ),
            ),
            backgroundColor:
                Colors.black.withOpacity(0.7), // ✅ Black transparent
            duration: const Duration(seconds: 3),
            //behavior: SnackBarBehavior.floating, // Optional: makes it float nicely
            shape: RoundedRectangleBorder(
              // Optional: rounded corners
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );

        print('Logout failed: ${response.body}');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Do you want to close the app?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No")),
            TextButton(
                onPressed: () async {
                  exit(0);
                },
                child: const Text("Yes")),
          ],
        );
      },
    );
    return exitApp;
  }

  @override
  void initState() {
    super.initState();
    profiledata();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      profiledata();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      onPopInvoked: (didpop) {
        _onBackButtonPressed(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Full screen width
                height:
                    MediaQuery.of(context).size.height, // Full screen height
                child: Lottie.asset("assets/images/loginbg.json",
                    fit: BoxFit.cover),
              ),
            ),
            Container(
              color: Colors.lightBlueAccent
                  .withOpacity(0.1), // adjust opacity as needed
            ),
            SafeArea(
                child: Container(
              width: 210,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: DrawerHeader(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              maxRadius: 60,
                              child: Lottie.asset(
                                'assets/images/profile_icon_lottie.json',
                                height: size.height * 0.4,
                                width: size.width * 0.4,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              userName ?? "",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: ListView(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ProfileScreen();
                              }));
                            },
                            leading: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Profile",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    duration: const Duration(milliseconds: 300),
                                    child: IncidentListPage()),
                              );
                            },
                            leading: const Icon(
                              Icons.system_security_update_warning,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Incident",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                      const AboutUsPage()),
                                      (Route<dynamic> route) => false);
                            },
                            leading: const Icon(
                              Icons.info_rounded,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "About Us",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            onTap: () async {
                              logoutUser(context);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const OnboardingScreen()),
                                  (Route<dynamic> route) => false);
                            },
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Log out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            )),
            TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(milliseconds: 300),
                builder: (_, double val, __) {
                  return (Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..setEntry(0, 3, 200 * val)
                        ..rotateY((pi / 6) * val),
                      child: const PatrolDashboard()));
                  //child: PatrolDashboardScreen()));
                }),
            GestureDetector(
              onHorizontalDragUpdate: (e) {
                if (e.delta.dx > 0) {
                  setState(() {
                    value = 1;
                  });
                } else {
                  setState(() {
                    value = 0;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
