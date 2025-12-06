import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flip/theme/app_colors.dart';

import 'task_section_card.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    required this.allDay,
    required this.startDateTime,
    required this.endDateTime,
    required this.reminderEnabled,
    required this.reminders,
    required this.pinned,
    required this.onAllDayChanged,
    required this.onStartTap,
    required this.onEndTap,
    required this.onReminderToggle,
    required this.onReminderRemove,
    required this.onAddReminderTap,
    required this.onRepeatTap,
    required this.onPinnedChanged,
    this.repeatText,
    this.repeatEndDate,
    this.onRemoveRepeat,
    this.onRemoveRepeatEndDate,
    super.key,
  });

  final bool allDay;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool reminderEnabled;
  final List<String> reminders;
  final bool pinned;
  final ValueChanged<bool> onAllDayChanged;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final ValueChanged<bool> onReminderToggle;
  final ValueChanged<int> onReminderRemove;
  final VoidCallback onAddReminderTap;
  final VoidCallback onRepeatTap;
  final ValueChanged<bool> onPinnedChanged;

  /// Hiển thị thông tin lặp lại (ví dụ: "Mỗi 4 Thứ Bảy")
  final String? repeatText;

  /// Ngày kết thúc lặp lại (nếu có)
  final DateTime? repeatEndDate;

  /// Xóa lặp lại
  final VoidCallback? onRemoveRepeat;

  /// Xóa ngày kết thúc lặp lại
  final VoidCallback? onRemoveRepeatEndDate;

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.calendar_month,
            title: 'Cả ngày',
            trailing: Switch(
              value: allDay,
              activeThumbColor: AppColors.xanh1,
              onChanged: onAllDayChanged,
            ),
          ),
          const SizedBox(height: 10),
          _DateRow(
            label: 'Bắt đầu',
            icon: Icons.arrow_forward,
            dateTime: startDateTime,
            allDay: allDay,
            onTap: onStartTap,
          ),
          const SizedBox(height: 10),
          _DateRow(
            label: 'Kết thúc',
            icon: Icons.arrow_back,
            dateTime: endDateTime,
            allDay: allDay,
            onTap: onEndTap,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _SectionHeader(
            icon: Icons.event_note,
            title: 'Nhắc nhở',
            trailing: Switch(
              value: reminderEnabled,
              activeThumbColor: AppColors.xanh1,
              onChanged: onReminderToggle,
            ),
          ),
          if (reminderEnabled) ...[
            const SizedBox(height: 12),
            // Hiển thị nhắc nhở đã chọn (nếu có) với nút xóa
            if (reminders.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xanhLa1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.xanhLa1.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.xanhLa2,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reminders.first,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onReminderRemove(0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Nút "Chọn thời gian nhắc nhở" luôn hiển thị
            _ActionRow(
              icon: Icons.add_circle_outline,
              title: 'Chọn thời gian nhắc nhở',
              onTap: onAddReminderTap,
              textColor: AppColors.xanh1,
            ),
            const SizedBox(height: 12),
          ],
          // Nút lặp lại - luôn hiển thị
          if (repeatText != null && repeatText!.isNotEmpty) ...[
            // Hiển thị repeat text
            GestureDetector(
              onTap: onRepeatTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xanh1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.xanh1.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.autorenew_rounded,
                      color: AppColors.xanh1,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        repeatText!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (onRemoveRepeat != null)
                      GestureDetector(
                        onTap: onRemoveRepeat,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Hiển thị ngày kết thúc lặp lại nếu có hoặc nút chọn
            if (repeatEndDate != null)
              GestureDetector(
                onTap: onRepeatTap,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cam.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.cam.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.cam,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kết thúc: ${DateFormat('dd/MM/yyyy').format(repeatEndDate!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (onRemoveRepeatEndDate != null)
                        GestureDetector(
                          onTap: onRemoveRepeatEndDate,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onRepeatTap,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cam.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.cam.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.cam,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chọn ngày kết thúc',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            // Hiển thị nút "Không bao giờ"
            _ActionRow(
              icon: Icons.autorenew_rounded,
              title: 'Không bao giờ',
              onTap: onRepeatTap,
            ),
          ],
          if (reminderEnabled) const SizedBox(height: 8),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _SectionHeader(
            icon: Icons.push_pin,
            title: 'Ghim',
            trailing: Switch(
              value: pinned,
              activeThumbColor: AppColors.xanh1,
              onChanged: onPinnedChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.xanhLa2, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.icon,
    required this.dateTime,
    required this.allDay,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final DateTime dateTime;
  final bool allDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDateOnly(dateTime);
    final timeText = allDay
        ? ''
        : _formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.xanhLa2, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!allDay)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppColors.xanhLa2, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDateOnly(DateTime dateTime) {
  final formatter = DateFormat("EEE, dd 'thg' MM, yyyy", 'vi');
  return formatter.format(dateTime);
}
