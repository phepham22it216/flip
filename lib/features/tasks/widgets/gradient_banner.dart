// lib/widgets/gradient_banner.dart
import 'package:flutter/material.dart';

/// GradientBanner: banner có gradient, icon trái, text chính và badge (số)
/// - text: nội dung chính
/// - icon: icon ở trái
/// - badge: chuỗi hiển thị ở bên phải (ví dụ '7'), truyền '' để ẩn
/// - onTap: callback khi bấm
/// - start/end: màu gradient (tuỳ chỉnh)
class GradientBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final String badge;
  final VoidCallback? onTap;
  final Color start;
  final Color end;
  final double borderRadius;
  final EdgeInsets padding;

  const GradientBanner({
    super.key,
    required this.text,
    this.icon = Icons.work_outline,
    this.badge = '',
    this.onTap,
    this.start = const Color(0xFFFFA726), // cam nhạt
    this.end = const Color(0xFFFF7043), // cam đậm
    this.borderRadius = 14.0,
    this.padding = const EdgeInsets.all(14.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [start, end],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // icon left
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 14),

                // text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // small hint line under (optional)
                      // Text('Miêu tả ngắn', style: theme.textTheme.caption?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),

                // badge + arrow
                if (badge.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
