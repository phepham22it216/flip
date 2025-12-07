import 'package:flip/features/more/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flip/features/more/screens/signup_page.dart';
import '../../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  // Controllers  ----------------------------------------------------- //
  final TextEditingController emailController = TextEditingController();     // <-- added
  final TextEditingController passController = TextEditingController();      // <-- added

  // Password visibility
  bool _obscurePassword = true;

  // Helper: show message --------------------------------------------- //
  void showMsg(BuildContext context, String text) {                        // <-- added
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
              Color(0xff063360), // màu đậm phía trên
              Color(0xff7fb5e4), // nhạt dần xuống dưới
              Color(0xff063f7a),
            ],
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.transparent, // Background màu yêu cầu
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Ảnh login.png
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(74),
                      child: Image.asset(
                        "assets/images/login.jpg",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    " ~ Login ~",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Form container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Email
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Enter your email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        TextField(
                          controller: passController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Enter your password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFB0B8F3), // xanh bạn chọn
                                Color(0xFF4B89D1), // xanh đậm hơn
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final email = emailController.text.trim();
                              final pass  = passController.text.trim();

                              if (email.isEmpty || pass.isEmpty) {
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

                              try {
                                final user = await AuthService().loginWithEmail(
                                  email: email,
                                  password: pass,
                                );

                                if (user == null) {
                                  showMsg(context, "Login failed. Please check your credentials.");
                                  return; // Không chuyển hướng
                                }

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MainScreen()),   // <-- navigate to main
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
                              "Login with Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text("Or continue with"),
                        const SizedBox(height: 12),

                        // Google button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            icon: Image.asset("assets/icons/google.png", height: 22),
                            label: const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                            ),
                            onPressed: () async {
                              try {
                                final user = await AuthService().loginWithGoogle();

                                if (user == null) {
                                  // Đăng nhập thất bại
                                  showMsg(context, "Google Sign-In failed. Please try again.");
                                  return; // Không chuyển hướng
                                }

                                print("✅ Logged in user:");
                                print("Name: ${user.fullName}");
                                print("Email: ${user.email}");

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MainScreen()),
                                );
                              } catch (e) {
                                showMsg(context, e.toString());
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Signup link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupScreen()),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // fontStyle: FontStyle.italic,
                            color: Color(0xFFE15142),
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



