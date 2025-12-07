import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background cong
          Positioned.fill(child: CustomPaint(painter: _BottomBarPainter())),

          // 4 item: Task, Home | Team, More
          Positioned.fill(
            top: 12, // đẩy icon xuống 1 chút
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.task_alt,
                  label: 'Task',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavBarItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: 64), // chừa chỗ cho nút +
                _NavBarItem(
                  icon: Icons.groups,
                  label: 'Team',
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavBarItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Account',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),

          // Nút + ở giữa, nổi lên trên
          Positioned(
            top: -24,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onCenterTap,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.xanh1,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.xanh1 : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.xanh1 : Colors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vẽ thanh menu màu trắng, cong ở giữa giống hình
class _BottomBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    final path = Path();
    const double topHeight = 24; // chiều cao phần cong so với mép trên
    const double radius = 32; // bán kính chỗ lõm cho nút +

    // bắt đầu từ góc trái
    path.moveTo(0, topHeight);

    // đoạn cong từ trái vào gần giữa
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);

    // chỗ lõm ở giữa cho nút +
    path.arcToPoint(
      Offset(size.width * 0.65, 0),
      radius: const Radius.circular(radius),
      clockwise: false, // false để cong lõm xuống
    );

    // cong từ giữa ra phải
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, topHeight);

    // viền dưới
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // đổ bóng nhẹ
    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
