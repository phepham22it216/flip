import 'package:flip/features/tasks/screens/group_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/core/widgets/bottom_nav_bar.dart';
import 'package:flip/core/widgets/main_header.dart';
import 'package:flip/features/tasks/screens/task_list_page.dart';
import 'package:flip/features/home/screens/home_page.dart';
import 'package:flip/features/team/screens/team_page.dart';
import 'package:flip/features/more/screens/account_page.dart';
import 'package:flip/features/tasks/screens/task_create_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flip/features/more/screens/login_page.dart';
import 'core/services/notify_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip/features/more/services/auth_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flip/features/home/screens/ai_chat_page.dart'; // đảm bảo file này tồn tại

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1 lần initializeApp duy nhất với options cho web/android/ios
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sau khi Firebase init xong thì init các thứ khác
  initGoogleSignIn(); // hàm trong auth_service.dart — gọi sau khi Firebase init

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await NotifyService().initMobile();

  await initializeDateFormatting('vi_VN', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đa Nền Tảng',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      // Điều hướng dựa trên trạng thái auth (nếu đã login -> MainScreen, chưa -> LoginScreen)
      home: const AuthGate(),
    );
  }
}

/// AuthGate chỉ nhận diện trạng thái đăng nhập
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // đang load trạng thái auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // nếu có user -> vào main
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }
        // ngược lại show login
        return const LoginScreen();
      },
    );
  }
}

/// MainScreen chứa toàn bộ UI chính (pages, bottom nav, fab chat)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TaskListPage(),
    HomePage(),
    GroupListPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainHeader(), // 👈 header FLIP cố định
      // body = nội dung từng tab
      body: _pages[_currentIndex],

      // ---------- Floating chat button ----------
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          bottom: 70,
          right: 10,
        ), // tránh che bottom nav
        child: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AIChatPage()));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4A90E2), // xanh nhạt
                  Color(0xFF1976D2), // xanh đậm FLIP
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ---------- Bottom bar (giữ logic onCenterTap) ----------
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onCenterTap: () {
          // vẫn mở TaskCreate như trước; nếu muốn đổi thành Chat thì đổi dòng dưới
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TaskCreatePage()));

          // Nếu bạn muốn center button mở Chat thay vì TaskCreate, comment 2 dòng trên
          // và dùng:
          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AIChatPage()));
        },
      ),
    );
  }
}
