import 'package:be_ui/model/user.dart';
import 'package:flutter/material.dart';
import 'package:be_ui/provider/userprovider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        title: Text(
          'Profile Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[100],
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blueGrey[100]),
      ),

      // ✅ Selector to get entire user once for null check
      body: Selector<UserProvider, User?>(
        selector: (_, provider) => provider.user,
        builder: (context, user, child) {
          if (user == null) return buildLoadingIndicator();

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Lottie.asset(
                          'assets/images/profile_icon_lottie.json',
                          height: 175,
                          width: 175,
                        ),
                      ),
                      Divider(
                        height: 60.0,
                        color: Colors.blueGrey[300],
                        thickness: 1.2,
                      ),

                      buildLabel('NAME'),
                      Selector<UserProvider, String?>(
                        selector: (_, provider) => provider.user?.name,
                        builder: (context, name, _) =>
                            buildValue(name ?? ''),
                      ),
                      const SizedBox(height: 25.0),

                      buildLabel('ROLE'),
                      Selector<UserProvider, String?>(
                        selector: (_, provider) => provider.user?.role,
                        builder: (context, role, _) =>
                            buildValue(role ?? ''),
                      ),
                      const SizedBox(height: 25.0),

                      buildLabel('DOB'),
                      Selector<UserProvider, String?>(
                        selector: (_, provider) => provider.user?.phone,
                        builder: (context, phone, _) =>
                            buildValue(phone ?? ''),
                      ),
                      const SizedBox(height: 25.0),

                      buildLabel('BADGE'),
                      Selector<UserProvider, String?>(
                        selector: (_, provider) => provider.user?.badgeNumber,
                        builder: (context, badge, _) =>
                            buildValue(badge ?? ''),
                      ),
                      const SizedBox(height: 25.0),

                      buildLabel('DEPARTMENT'),
                      Selector<UserProvider, String?>(
                        selector: (_, provider) => provider.user?.department,
                        builder: (context, dept, _) =>
                            buildValue(dept ?? ''),
                      ),
                      const SizedBox(height: 15.0),

                      Row(
                        children: [
                          const Icon(Icons.email,
                              color: Colors.lightBlueAccent),
                          const SizedBox(width: 10.0),
                          Selector<UserProvider, String?>(
                            selector: (_, provider) => provider.user?.email,
                            builder: (context, email, _) => TextButton(
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    'mailto:${email ?? ''}?subject=FeedBack'));
                              },
                              child: Text(
                                email ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      Row(
                        children: [
                          const Icon(Icons.call,
                              color: Colors.lightBlueAccent),
                          const SizedBox(width: 10.0),
                          const Text(
                            "+91",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Selector<UserProvider, String?>(
                            selector: (_, provider) => provider.user?.phone,
                            builder: (context, phone, _) => TextButton(
                              onPressed: () {
                                launchUrl(Uri.parse('tel:$phone'));
                              },
                              child: Text(
                                phone ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Utility Widgets
Widget buildLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.blueGrey[100],
      letterSpacing: 1.5,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );
}

Widget buildValue(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: Colors.amberAccent,
      letterSpacing: 1.5,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildLoadingIndicator() {
  return Center(
    child: Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.lightBlueAccent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 4),
          const SizedBox(height: 20),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: Colors.blueGrey[100],
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ),
  );
}
