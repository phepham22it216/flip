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

  String hash = "";
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
        emailController.text = maskEmail(user.email);
        passwordMasked = "********"; // luôn ẩn mật khẩu
        hash = user.passwordHash ?? "";;
        print("Real password hash 1 = $hash");
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
        showMsg("Đã cập nhật avatar!");
      } else {
        showMsg("Cập nhật không thành công!");
      }
    } catch (e) {
      showMsg("Failed to update avatar: $e");
    }
  }

  void _saveName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showMsg("Vui lòng điền họ tên!");
      return;
    }
    try {
      await AuthService().updateFullName(name);
      showMsg("Cập nhật thành công!");
      setState(() {
        isEditingName = false;
      });
    } catch (e) {
      showMsg(e.toString());
    }
  }

  String maskEmail(String email) {
    final atIndex = email.indexOf("@");
    if (atIndex == -1) return email; // fallback

    final firstFive = email.substring(0, email.length < 5 ? email.length : 5);
    final domain = email.substring(atIndex);

    return "$firstFive***$domain";
  }

  Future<String?> _askPasswordDialog() async {
    final controller = TextEditingController();
    bool obscure = true; // chỉ thêm biến UI, không thay đổi logic

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: const Color(0xFF90CAF9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Nhập mât khẩu ở đây",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  // ================= TEXTFIELD PASSWORD ================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: controller,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: "Mật khẩu cũ",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= BUTTONS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E0E0),
                        ),
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFC8E6C9),
                        ),
                        onPressed: () =>
                            Navigator.pop(context, controller.text.trim()),
                        child: const Text(
                          "Xác nhận",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveEmail() async {
    final newEmail = emailController.text.trim();
    final user = await AuthService().currentUser();

    if (newEmail.isEmpty) {
      showMsg("Vui lòng nhập email!");
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(newEmail)) {
      showMsg("Sai định dạng!");
      return;
    }

    if (user == null) {
      showMsg("Tài khoản không tồn tại!");
      return;
    }

    // YÊU CẦU MẬT KHẨU ĐỂ XÁC THỰC
    final oldPassword = await _askPasswordDialog();
    if (oldPassword == null) return;

    try {
      final result = await AuthService().updateEmail(
        newEmail,
        user.email,      // email hiện tại
        oldPassword,     // mật khẩu xác thực
      );

      if (result == "VERIFY_EMAIL_SENT") {
        showMsg("Link xác thực đã được gửi đến $newEmail. Hãy xác nhận!");
        setState(() {
          isEditingEmail = false;
          emailController.text = maskEmail(newEmail);
        });
      } else {
        showMsg("Cập nhật không thành công!");
      }
    } catch (e) {
      showMsg(e.toString());
    }
  }

  void _changePassword() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final rePassController = TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureRe = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: const Color(0xFF90CAF9), // blue đậm hơn nền 30%
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Sửa Mật Khẩu",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                // ========== OLD PASSWORD ==========
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: oldPassController,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu cũ",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                            obscureOld ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ========== NEW PASSWORD ==========
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: newPassController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu mới",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                            obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ========== CONFIRM NEW PASSWORD ==========
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: rePassController,
                    obscureText: obscureRe,
                    decoration: InputDecoration(
                      labelText: "Nhập lại MK mới",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                            obscureRe ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => obscureRe = !obscureRe),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child:
                      const Text("Hủy", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),

                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFC8E6C9),
                      ),
                      onPressed: () async {
                        final oldPass = oldPassController.text.trim();
                        final newPass = newPassController.text.trim();
                        final rePass = rePassController.text.trim();

                        if (oldPass.isEmpty || newPass.isEmpty || rePass.isEmpty) {
                          showMsg("Hãy nhập đầy đủ các trường!");
                          return;
                        }
                        if (newPass.length < 6) {
                          showMsg("Mật khẩu không được nhỏ hơn 6 kí tự.");
                          return;
                        }
                        if (newPass != rePass) {
                          showMsg("Bạn nhập chưa khớp mật khẩu.");
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
                      child:
                      const Text("Lưu", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đăng Xuất"),
        content: const Text("Bạn muốn đăng xuất?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
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
            child: const Text("OK"),
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
                              : const AssetImage("assets/images/account.png")),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Nhấp vào avatar để thay đổi!",
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
                    title: "Họ và tên",
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
                    onTapEdit: () {
                      if (hash.isEmpty) {
                        showMsg("Tài khoản GG không thể sửa email!");
                        return;
                      }
                      AuthService().currentUser().then((user) {
                        if (user != null) {
                          setState(() {
                            emailController.text = user.email ?? "";
                            isEditingEmail = true;
                          });
                        }
                      });
                    },
                    onSave: _saveEmail,
                  ),

                  const SizedBox(height: 15),

                  _infoCard(
                    title: "Mật khẩu",
                    icon: Icons.lock,
                    iconColor: Colors.black87,
                    controller: TextEditingController(text: passwordMasked),
                    isPassword: true,
                    isEditing: false,
                    onTapEdit: () {
                      print("Real password hash = '$hash'");

                      // nếu hash rỗng → không có password
                      if (hash.isEmpty || hash.trim().isEmpty) {
                        showMsg("Tài khoản của bạn là tài khoản GG, không thể thay đổi MK!");
                        return;
                      }

                      _changePassword(); // OK
                    },
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
                  "Đăng xuất",
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
