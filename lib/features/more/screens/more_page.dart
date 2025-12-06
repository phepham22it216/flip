import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Màn hình More sẽ được thiết kế sau',
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
