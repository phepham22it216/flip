import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/core/widgets/bottom_nav_bar.dart';
import 'package:flip/core/widgets/main_header.dart';
import 'package:flip/features/tasks/screens/task_list_page.dart';
import 'package:flip/features/home/screens/home_page.dart';
import 'package:flip/features/team/screens/team_page.dart';
import 'package:flip/features/more/screens/more_page.dart';
import 'package:flip/features/tasks/screens/task_create_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('vi_VN', null).then((_) {
    runApp(const MyApp());
  });
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
      home: const MainScreen(),
    );
  }
}

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
    TeamPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainHeader(), // 👈 header FLIP cố định
      body: _pages[_currentIndex], // 👈 nội dung từng tab
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onCenterTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TaskCreatePage()));
        },
      ),
    );
  }
}
