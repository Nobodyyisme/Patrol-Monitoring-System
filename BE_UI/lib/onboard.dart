import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:be_ui/homepage.dart';
import 'package:be_ui/forgotpassword.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  TextEditingController nameController = TextEditingController(text: "officer1@example.com");
  TextEditingController passwordController = TextEditingController(text: 'password123');
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background animations
          SizedBox.expand(
            child: Lottie.asset("assets/images/loginbg.json", fit: BoxFit.cover),
          ),
          SizedBox.expand(
            child: Lottie.asset("assets/images/loginbtn.json", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: const SizedBox(),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: 270,
                    child: Text(
                      "Let's Route!",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          fontSize: 50,
                          color: Color(0xffffffffcd),
                          fontFamily: "poppins"),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 76,
                    width: 350,
                    child: Text(
                      "You are using the 21st century's most advanced mobile application, you can increase productivity, manage tasks, and receive alerts.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          fontFamily: "poppins"),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Login form at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: nameController,
                          validator: (val) {
                            if (val == null || val.isEmpty || RegExp(r"\s").hasMatch(val)) {
                              return "Email must not be empty";
                            } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-z]+\.[a-z]{2,3}$").hasMatch(val)) {
                              return "Enter a valid Email";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            border: InputBorder.none,
                            hintText: 'Example123@gmail.com',
                            hintStyle: GoogleFonts.cantarell(
                                fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w400),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Icon(Icons.email_outlined,
                                  color: Color.fromRGBO(34, 87, 126, 1), size: 30.0),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.cantarell(fontSize: 20, color: Colors.black),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),
                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          validator: (val) {
                            if (val == null || val.isEmpty || RegExp(r"\s").hasMatch(val)) {
                              return "Use Proper Password";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            border: InputBorder.none,
                            hintText: 'Password123',
                            hintStyle: GoogleFonts.cantarell(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Icon(Icons.lock,
                                  color: Color.fromRGBO(34, 87, 126, 1), size: 30.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Color.fromRGBO(34, 87, 126, 1),
                                size: 25.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.cantarell(fontSize: 20, color: Colors.black),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => forgot_password()),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            onPressed: () {
                              if (formkey.currentState!.validate()) {
                                loginUser(context, [nameController, passwordController]);
                              }
                            },
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Login function remains unchanged
void loginUser(context, List<TextEditingController> controller) async {
  try {
    final loginUrl = Uri.parse("https://patrol-monitoring-system1.onrender.com/api/auth/login");

    final response = await http.post(
      loginUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": controller.first.text, "password": controller.last.text}),
    );

    if (response.statusCode == 200) {
      final loginData = jsonDecode(response.body);
      final userData = loginData['user'];
      final token = loginData['token'];

      SharedPreferences preference = await SharedPreferences.getInstance();
      preference.setString('id', userData['id']);
      preference.setString('name', userData['name']);
      preference.setString('email', userData['email']);
      preference.setString('role', userData['role']);
      preference.setString('token', token);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const U_homepage()),
            (Route<dynamic> route) => false,
      );
    } else {
      controller.forEach((element) => element.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Login failed. Please check your credentials.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      );
    }
  } catch (e) {
    print("An error occurred: $e");
  }
}
