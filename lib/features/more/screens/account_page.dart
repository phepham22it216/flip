import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import 'login_page.dart';
import 'package:image_picker/image_picker.dart'; // để chọn ảnh
import 'dart:io';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String passwordMasked = "********"; // hiển thị pass dạng *******
  String avatarUrl = ""; // url avatar từ Firebase/Cloudinary

  bool isEditingName = false;
  bool isEditingEmail = false;

  File? _localImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // Giả sử AuthService().currentUser trả về user object
    final user = await AuthService().currentUser();
    if (user != null) {
      setState(() {
        nameController.text = user.fullName ?? "";
        emailController.text = user.email ?? "";
        passwordMasked = "********"; // luôn ẩn mật khẩu
        avatarUrl = (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
            ? user.avatarUrl!
            : "assets/images/account.png";
      });
    } else {
      // Nếu không lấy được user, avatar mặc định
      setState(() {
        avatarUrl = "assets/images/account.png"; // fixed here
      });
    }
  }

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null) return;

    try {
      String uploadedUrl = "";

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        uploadedUrl = (await CloudinaryService().uploadBytes(bytes, pickedFile.name)) ?? "";
      } else {
        final file = File(pickedFile.path);
        uploadedUrl = (await CloudinaryService().uploadFile(file)) ?? "";
      }

      if (uploadedUrl.isNotEmpty) {
        await AuthService().updateAvatar(uploadedUrl); // fixed here
        setState(() {
          avatarUrl = uploadedUrl; // fixed null-safe
          if (!kIsWeb) _localImage = File(pickedFile.path);
        });
        showMsg("Avatar updated!");
      } else {
        showMsg("Failed to upload avatar!");
      }
    } catch (e) {
      showMsg("Failed to update avatar: $e");
    }
  }

  void _saveName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showMsg("Full Name cannot be empty!");
      return;
    }
    try {
      await AuthService().updateFullName(name);
      showMsg("Full Name updated!");
      setState(() {
        isEditingName = false;
      });
    } catch (e) {
      showMsg(e.toString());
    }
  }

  void _saveEmail() async {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      showMsg("Email cannot be empty!");
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      showMsg("Email is invalid!");
      return;
    }
    try {
      await AuthService().updateEmail(email);
      showMsg("Email updated!");
      setState(() {
        isEditingEmail = false;
      });
    } catch (e) {
      showMsg(e.toString());
    }
  }

  void _changePassword() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final rePassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Old Password",
              ),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),
            TextField(
              controller: rePassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPass = oldPassController.text.trim();
              final newPass = newPassController.text.trim();
              final rePass = rePassController.text.trim();

              if (oldPass.isEmpty || newPass.isEmpty || rePass.isEmpty) {
                showMsg("Please fill in all fields!");
                return;
              }
              if (newPass.length < 6) {
                showMsg("New password must be at least 6 characters!");
                return;
              }
              if (newPass != rePass) {
                showMsg("Passwords do not match!");
                return;
              }

              try {
                await AuthService().updatePassword(oldPass, newPass);
                showMsg("Password updated!");
                Navigator.pop(ctx);
              } catch (e) {
                showMsg(e.toString());
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ------------ BANNER + AVATAR -----------
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  "assets/images/UTE.png",
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),

                Positioned(
                  top: 105, // avatar thụt xuống
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 80, // avatar lớn hơn
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!)
                              : (avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl) as ImageProvider
                              : const AssetImage("assets/images/avatar_placeholder.png")),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Tap avatar to change",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),

                      // THÊM VÙNG TRỐNG CHO AVATAR THÒ RA
                      Positioned(
                        bottom: -80, // avatar thò ra đúng 1/2
                        child: SizedBox(height: 80),
                      )
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 95),

            // ================= BOX TỔNG =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFC2E2FB), // xanh đậm hơn nền 30%
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  _infoCard(
                    title: "Full Name",
                    icon: Icons.person,
                    iconColor: Colors.blue.shade700,
                    controller: nameController,
                    isEditing: isEditingName,
                    onTapEdit: () => setState(() => isEditingName = true),
                    onSave: _saveName,
                  ),

                  const SizedBox(height: 15),

                  _infoCard(
                    title: "Email",
                    icon: Icons.email,
                    iconColor: Colors.red.shade600,
                    controller: emailController,
                    isEditing: isEditingEmail,
                    onTapEdit: () => setState(() => isEditingEmail = true),
                    onSave: _saveEmail,
                  ),

                  const SizedBox(height: 15),

                  _infoCard(
                    title: "Password",
                    icon: Icons.lock,
                    iconColor: Colors.black87,
                    controller: TextEditingController(text: passwordMasked),
                    isPassword: true,
                    isEditing: false,
                    onTapEdit: _changePassword,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ------------ LOGOUT BUTTON -----------
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF99DCFB), // xanh dương nhạt
                    Color(0xFFFFC8CD), // đỏ nhạt
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: Colors.lightBlueAccent,
                  width: 2,
                ),
              ),
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.transparent,
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    Colors.red.withOpacity(0.10),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required bool isEditing,
    Function()? onTapEdit,
    Function()? onSave,
    bool isPassword = false,
  }) {
    Color editColor = Colors.grey.shade700;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller: controller,
                enabled: isEditing,
                obscureText: isPassword,
                decoration: InputDecoration(
                  labelText: title,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),

            // ICON EDIT/SAVE
            MouseRegion(
              onEnter: (_) => editColor = Colors.black,
              onExit: (_) => editColor = Colors.grey.shade700,
              child: GestureDetector(
                onTap: isEditing ? onSave : onTapEdit,
                child: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: editColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
