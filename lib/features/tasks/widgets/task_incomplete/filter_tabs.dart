import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

enum TaskFilter { all, today, overdue, upcoming }

class FilterTabs extends StatelessWidget {
  final TaskFilter selectedFilter;
  final Function(TaskFilter) onFilterChanged;

  const FilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab('Tất cả', TaskFilter.all),
          _buildFilterTab('Hôm nay', TaskFilter.today),
          _buildFilterTab('Quá hạn', TaskFilter.overdue),
          _buildFilterTab('Sắp tới', TaskFilter.upcoming),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, TaskFilter filter) {
    final isSelected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.xanh1 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
