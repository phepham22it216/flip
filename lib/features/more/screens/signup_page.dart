import 'package:flutter/material.dart';
import 'package:flip/features/more/screens/login_page.dart';

import '../services/auth_service.dart';

// SIGNUP SCREEN
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers  ----------------------------------------------------- //
  final TextEditingController nameController = TextEditingController();       // <-- added
  final TextEditingController emailController = TextEditingController();      // <-- added
  final TextEditingController passController = TextEditingController();       // <-- added
  final TextEditingController repassController = TextEditingController();     // <-- added

  // Password visibility
  bool _obscurePass = true;
  bool _obscureRePass = true;

  void showMsg(BuildContext context, String text) {                           // <-- added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff5391d3), // màu đậm phía trên
              Color(0xffcbd9e8),
              Color(0xff639bd6), // nhạt dần xuống dưới
            ],
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Ảnh signup.png
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/signup.jpg",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "~ Sign Up ~",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Name
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        TextField(
                          controller: passController,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePass = !_obscurePass;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Confirm pass
                        TextField(
                          controller: repassController,
                          obscureText: _obscureRePass,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRePass ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureRePass = !_obscureRePass;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Signup button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6BA7DD), // xanh bạn chọn
                                Color(0xFF3D7ECF), // xanh đậm hơn
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final email = emailController.text.trim();
                              final pass = passController.text.trim();
                              final repass = repassController.text.trim();

                              if (name.isEmpty || email.isEmpty || pass.isEmpty || repass.isEmpty) {
                                showMsg(context, "Please fill in all fields!");
                                return;
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(email)) {
                                showMsg(context, "Please enter a valid email!");
                                return;
                              }
                              if (pass.length < 6) {
                                showMsg(context, "Password must be at least 6 characters!");
                                return;
                              }
                              if (pass != repass) {
                                showMsg(context, "Passwords do not match!");
                                return;
                              }

                              try {
                                final user = await AuthService().signUp(
                                  fullName: name,
                                  email: email,
                                  password: pass,
                                );

                                if (user == null) {
                                  // Đăng ký thất bại
                                  showMsg(context, "Sign-up failed. Please try again.");
                                  return; // Không chuyển hướng
                                }

                                // Đăng ký thành công → chuyển hướng về Login
                                showMsg(context, "Sign-up successful! Please login.");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginScreen()), // <-- go login
                                );
                              } catch (e) {
                                showMsg(context, e.toString());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF73F197),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}