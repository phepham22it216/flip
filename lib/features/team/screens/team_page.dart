import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Màn hình Team sẽ được thiết kế sau',
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
