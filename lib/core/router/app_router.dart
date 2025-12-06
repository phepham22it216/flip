import 'package:flutter/material.dart';
import '../../features/tasks/screens/task_list_page.dart';

class AppRouter {
  static const String taskList = '/tasks';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case taskList:
      default:
        return MaterialPageRoute(
          builder: (_) => const TaskListPage(),
        );
    }
  }
}
