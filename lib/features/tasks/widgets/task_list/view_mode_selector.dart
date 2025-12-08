import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

enum TaskViewType { list, calendar, matrix }

class ViewModeSelector extends StatefulWidget {
  final TaskViewType initialViewType;
  final ValueChanged<TaskViewType> onViewTypeChanged;

  const ViewModeSelector({
    super.key,
    this.initialViewType = TaskViewType.list,
    required this.onViewTypeChanged,
  });

  @override
  State<ViewModeSelector> createState() => _ViewModeSelectorState();
}

class _ViewModeSelectorState extends State<ViewModeSelector> {
  late TaskViewType _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = widget.initialViewType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildViewButton('CARD', TaskViewType.list),
            _buildDivider(),
            _buildViewButton('LỊCH', TaskViewType.calendar),
            _buildDivider(),
            _buildViewButton('MATRIX', TaskViewType.matrix),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 18, color: Colors.grey.shade300);
  }

  Widget _buildViewButton(String label, TaskViewType viewType) {
    final isActive = _viewType == viewType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = viewType;
          widget.onViewTypeChanged(_viewType);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.xanh1 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.xanh1.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
