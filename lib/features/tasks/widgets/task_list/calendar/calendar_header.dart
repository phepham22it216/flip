import 'package:flutter/material.dart';

import 'package:flip/features/tasks/widgets/task_list/calendar/calendar_view_mode.dart';
import 'package:flip/theme/app_colors.dart';

class CalendarHeader extends StatelessWidget {
  final String headerLabel;
  final CalendarViewMode viewMode;
  final ValueChanged<CalendarViewMode> onViewModeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const CalendarHeader({
    super.key,
    required this.headerLabel,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMonthNavigator(),
          const SizedBox(height: 8),
          _buildViewModeSelector(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleIconButton(Icons.chevron_left, onPrev),
        const SizedBox(width: 16),
        Text(
          headerLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 16),
        _circleIconButton(Icons.chevron_right, onNext),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildViewModeSelector() {
    final items = [
      (CalendarViewMode.month, 'THÁNG'),
      (CalendarViewMode.week, 'TUẦN'),
      (CalendarViewMode.day, 'NGÀY'),
    ];

    return Container(
      // padding nhỏ lại 1 chút
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final isSelected = viewMode == item.$1;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              // trước: 44 -> nhỏ lại cho “vừa tay”
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.xanhLa1 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => onViewModeChanged(item.$1),
                style: TextButton.styleFrom(
                  foregroundColor: isSelected
                      ? Colors.white
                      : Colors.grey.shade600,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 13, // trước: 14
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
