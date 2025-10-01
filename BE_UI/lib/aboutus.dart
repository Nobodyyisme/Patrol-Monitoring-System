import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/dev_team_logo.png'), // Your logo
            ),
            const SizedBox(height: 16),

            const Text(
              'We Build Modern Apps',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const Text(
              'We are a team of passionate developers who love building robust, beautiful, and scalable applications using modern technologies. From Flutter mobile apps to full-stack web apps with MERN, we do it all.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Tech Stack Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Our Tech Stack',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.phone_android),
                      title: Text('Flutter (Mobile & Web)'),
                    ),
                    ListTile(
                      leading: Icon(Icons.language),
                      title: Text('React.js & Next.js (Frontend)'),
                    ),
                    ListTile(
                      leading: Icon(Icons.api),
                      title: Text('Express.js & Node.js (Backend)'),
                    ),
                    ListTile(
                      leading: Icon(Icons.storage),
                      title: Text('MongoDB (Database)'),
                    ),
                    ListTile(
                      leading: Icon(Icons.bug_report),
                      title: Text('Postman (API Testing)'),
                    ),
                    ListTile(
                      leading: Icon(Icons.android),
                      title: Text('Android Native (Java/Kotlin)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Contact Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.indigo),
                      title: Text('devteam@yourcompany.com'),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.indigo),
                      title: Text('Remote / Global Team'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
