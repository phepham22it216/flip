import 'package:flutter/material.dart';
import 'package:flip/features/tasks/widgets/task_edit/schedule_card.dart';
import 'package:flip/features/tasks/widgets/task_create/mode_card.dart';
import 'package:flip/features/tasks/widgets/task_create/group_card.dart';
import 'package:flip/features/tasks/widgets/task_create/priority_card.dart';
import 'package:flip/features/tasks/widgets/task_create/difficulty_card.dart';
import 'package:flip/features/tasks/widgets/task_edit/color_card.dart';
import 'package:flip/features/tasks/widgets/task_edit/update_button.dart';
import 'package:flip/theme/app_colors.dart';

typedef BoolCallback = Function(bool);
typedef IntCallback = Function(int);
typedef StringCallback = Function(String);

class EditBottomSheetContent extends StatelessWidget {
  final TextEditingController noteController;
  final bool allDay;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool reminderEnabled;
  final List<String> reminders;
  final bool pinned;
  final String? repeatText;
  final DateTime? repeatEndDate;
  final bool isGroupMode;
  final String selectedGroup;
  final List<String> groups;
  final int selectedPriority;
  final int selectedDifficulty;
  final List<TaskColorOption> colorOptions;
  final int selectedColorIndex;
  final VoidCallback onAllDayChanged;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final VoidCallback onReminderToggle;
  final IntCallback onReminderRemove;
  final VoidCallback onAddReminderTap;
  final VoidCallback onRepeatTap;
  final VoidCallback onPinnedChanged;
  final VoidCallback onRemoveRepeat;
  final VoidCallback onRemoveRepeatEndDate;
  final BoolCallback onModeChanged;
  final StringCallback onGroupChanged;
  final IntCallback onPriorityChanged;
  final IntCallback onDifficultyChanged;
  final IntCallback onColorSelected;
  final VoidCallback onCustomColor;
  final VoidCallback onUpdatePressed;

  const EditBottomSheetContent({
    super.key,
    required this.noteController,
    required this.allDay,
    required this.startDateTime,
    required this.endDateTime,
    required this.reminderEnabled,
    required this.reminders,
    required this.pinned,
    required this.repeatText,
    required this.repeatEndDate,
    required this.isGroupMode,
    required this.selectedGroup,
    required this.groups,
    required this.selectedPriority,
    required this.selectedDifficulty,
    required this.colorOptions,
    required this.selectedColorIndex,
    required this.onAllDayChanged,
    required this.onStartTap,
    required this.onEndTap,
    required this.onReminderToggle,
    required this.onReminderRemove,
    required this.onAddReminderTap,
    required this.onRepeatTap,
    required this.onPinnedChanged,
    required this.onRemoveRepeat,
    required this.onRemoveRepeatEndDate,
    required this.onModeChanged,
    required this.onGroupChanged,
    required this.onPriorityChanged,
    required this.onDifficultyChanged,
    required this.onColorSelected,
    required this.onCustomColor,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildTitleCard(),
          const SizedBox(height: 14),
          ScheduleCard(
            allDay: allDay,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            reminderEnabled: reminderEnabled,
            reminders: reminders,
            pinned: pinned,
            onAllDayChanged: (_) => onAllDayChanged(),
            onStartTap: onStartTap,
            onEndTap: onEndTap,
            onReminderToggle: (_) => onReminderToggle(),
            onReminderRemove: onReminderRemove,
            onAddReminderTap: onAddReminderTap,
            onRepeatTap: onRepeatTap,
            onPinnedChanged: (_) => onPinnedChanged(),
            repeatText: repeatText,
            repeatEndDate: repeatEndDate,
            onRemoveRepeat: onRemoveRepeat,
            onRemoveRepeatEndDate: onRemoveRepeatEndDate,
          ),
          const SizedBox(height: 14),
          ModeCard(isGroupMode: isGroupMode, onModeChanged: onModeChanged),
          const SizedBox(height: 14),
          if (isGroupMode)
            GroupCard(
              selectedGroup: selectedGroup,
              onGroupChanged: onGroupChanged,
              groups: groups,
            ),
          if (isGroupMode) const SizedBox(height: 14),
          PriorityCard(
            selectedPriority: selectedPriority,
            onPriorityChanged: onPriorityChanged,
          ),
          const SizedBox(height: 14),
          DifficultyCard(
            selectedDifficulty: selectedDifficulty,
            onDifficultyChanged: onDifficultyChanged,
          ),
          const SizedBox(height: 14),
          ColorCard(
            colorOptions: colorOptions,
            selectedIndex: selectedColorIndex,
            onSelect: onColorSelected,
            onCustomColor: onCustomColor,
          ),
          const SizedBox(height: 24),
          UpdateButton(onPressed: onUpdatePressed),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Thêm chi tiết',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onCustomColor,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            icon: const Icon(Icons.add, color: AppColors.xanh1),
            label: const Text(
              'Sticker',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
