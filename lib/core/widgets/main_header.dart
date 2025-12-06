import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/core/widgets/notification_button.dart';

class MainHeader extends StatelessWidget implements PreferredSizeWidget {
  const MainHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Để cân đối với nút thông báo bên phải
                const SizedBox(width: 48),

                const Text(
                  'FLIP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: AppColors.xanh3,
                  ),
                ),

                const NotificationButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
