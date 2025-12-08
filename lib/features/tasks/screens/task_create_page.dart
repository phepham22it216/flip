import 'package:flutter/material.dart';
import 'package:flip/features/tasks/widgets/task_create/color_card.dart';
import 'package:flip/features/tasks/widgets/task_create/schedule_card.dart';
import 'package:flip/features/tasks/widgets/task_create/title_card.dart';
import 'package:flip/features/tasks/widgets/task_create/repeat_dialog.dart';
import 'package:flip/features/tasks/widgets/task_create/group_card.dart';
import 'package:flip/features/tasks/widgets/task_create/priority_card.dart';
import 'package:flip/features/tasks/widgets/task_create/difficulty_card.dart';
import 'package:flip/features/tasks/widgets/task_create/mode_card.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:flip/features/tasks/models/task_constants.dart';

class TaskCreatePage extends StatefulWidget {
  const TaskCreatePage({super.key});

  @override
  State<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TaskService _taskService = TaskService();

  final List<TaskColorOption> _colorOptions = const [
    TaskColorOption(label: 'Tím 1', color: AppColors.tim1),
    TaskColorOption(label: 'Tím 2', color: AppColors.tim2),
    TaskColorOption(label: 'Hồng', color: AppColors.hong),
    TaskColorOption(label: 'Da', color: AppColors.da),
    TaskColorOption(label: 'Xanh 1', color: AppColors.xanh1),
    TaskColorOption(label: 'Xanh 2', color: AppColors.xanh2),
    TaskColorOption(label: 'Xanh 3', color: AppColors.xanh3),
    TaskColorOption(label: 'Cam', color: AppColors.cam),
    TaskColorOption(label: 'Vàng', color: AppColors.vang),
    TaskColorOption(label: 'Xanh lá 1', color: AppColors.xanhLa1),
    TaskColorOption(label: 'Xanh lá 2', color: AppColors.xanhLa2),
    TaskColorOption(label: 'Xanh lá 3', color: AppColors.xanhLa3),
  ];

  int _selectedColorIndex = 0;

  bool _allDay = false;
  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 1));

  bool _reminderEnabled = TaskConstants.defaultReminderEnabled;
  final List<String> _reminders = [];

  bool _pinned = TaskConstants.defaultPinned;

  String? _repeatText;
  DateTime? _repeatEndDate;

  // Mới thêm
  int _selectedPriority =
      TaskConstants.defaultPriority; // 1: Low, 2: Medium, 3: High
  int _selectedDifficulty =
      TaskConstants.defaultDifficulty; // 1: Easy, 2: Medium, 3: Hard
  bool _isGroupMode = false; // false: Personal, true: Group
  String _selectedGroup = 'Nhóm';

  final List<String> _groups = const ['Nhóm', 'Work', 'Personal', 'Shopping'];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              TitleCard(
                titleController: _titleController,
                noteController: _noteController,
                onAddSticker: () {},
              ),
              const SizedBox(height: 14),
              ScheduleCard(
                allDay: _allDay,
                startDateTime: _startDateTime,
                endDateTime: _endDateTime,
                reminderEnabled: _reminderEnabled,
                reminders: _reminders,
                pinned: _pinned,
                onAllDayChanged: (value) {
                  setState(() {
                    _allDay = value;
                    if (value) {
                      _startDateTime = DateTime(
                        _startDateTime.year,
                        _startDateTime.month,
                        _startDateTime.day,
                        0,
                        0,
                      );
                      _endDateTime = DateTime(
                        _endDateTime.year,
                        _endDateTime.month,
                        _endDateTime.day,
                        23,
                        59,
                      );
                    }
                  });
                },
                onStartTap: () => _pickDateTime(isStart: true),
                onEndTap: () => _pickDateTime(isStart: false),
                onReminderToggle: (value) =>
                    setState(() => _reminderEnabled = value),
                onReminderRemove: (index) =>
                    setState(() => _reminders.removeAt(index)),
                onAddReminderTap: _showAddReminderOptions,
                onRepeatTap: _showRepeatOptionsDialog,
                onPinnedChanged: (value) => setState(() => _pinned = value),
                repeatText: _repeatText,
                repeatEndDate: _repeatEndDate,
                onRemoveRepeat: () => setState(() => _repeatText = null),
                onRemoveRepeatEndDate: () =>
                    setState(() => _repeatEndDate = null),
              ),
              const SizedBox(height: 14),
              ModeCard(
                isGroupMode: _isGroupMode,
                onModeChanged: (isGroup) {
                  setState(() => _isGroupMode = isGroup);
                },
              ),
              const SizedBox(height: 14),
              if (_isGroupMode)
                GroupCard(
                  selectedGroup: _selectedGroup,
                  onGroupChanged: (value) =>
                      setState(() => _selectedGroup = value),
                  groups: _groups,
                ),
              if (_isGroupMode) const SizedBox(height: 14),
              PriorityCard(
                selectedPriority: _selectedPriority,
                onPriorityChanged: (priority) =>
                    setState(() => _selectedPriority = priority),
              ),
              const SizedBox(height: 14),
              DifficultyCard(
                selectedDifficulty: _selectedDifficulty,
                onDifficultyChanged: (difficulty) =>
                    setState(() => _selectedDifficulty = difficulty),
              ),
              const SizedBox(height: 14),
              ColorCard(
                colorOptions: _colorOptions,
                selectedIndex: _selectedColorIndex,
                onSelect: (index) =>
                    setState(() => _selectedColorIndex = index),
                onCustomColor: () {},
              ),
              const SizedBox(height: 18),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.xanh1,
      foregroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 80,
      leading: TextButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text(
          'Huỷ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'Tạo mục tiêu mới',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saveTask,
          child: const Text(
            'Lưu',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.xanh2,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: _saveTask,
        child: const Text(
          'Lưu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final current = isStart ? _startDateTime : _endDateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;

    if (_allDay) {
      setState(() {
        if (isStart) {
          _startDateTime = DateTime(date.year, date.month, date.day, 0, 0);
          if (_startDateTime.isAfter(_endDateTime)) {
            _endDateTime = _startDateTime.add(const Duration(hours: 1));
          }
        } else {
          _endDateTime = DateTime(date.year, date.month, date.day, 23, 59);
          if (_endDateTime.isBefore(_startDateTime)) {
            _startDateTime = _endDateTime.subtract(const Duration(hours: 1));
          }
        }
      });
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _startDateTime = selected;
        if (_startDateTime.isAfter(_endDateTime)) {
          _endDateTime = _startDateTime.add(const Duration(hours: 1));
        }
      } else {
        _endDateTime = selected;
        if (_endDateTime.isBefore(_startDateTime)) {
          _startDateTime = _endDateTime.subtract(const Duration(hours: 1));
        }
      }
    });
  }

  Future<void> _showAddReminderOptions() async {
    const options = [
      'Cả ngày',
      '5 phút trước',
      '10 phút trước',
      '15 phút trước',
      '30 phút trước',
      '1 giờ trước',
      '1 ngày trước',
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                    const Text(
                      'Thời gian nhắc nhở',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((option) {
                    return ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        setState(() {
                          _reminders
                            ..clear()
                            ..add(option);
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRepeatOptionsDialog() async {
    final result = await showRepeatDialog(context);
    if (result != null) {
      setState(() {
        _repeatText = result.repeatText;
        _repeatEndDate = result.endDate;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề task')),
      );
      return;
    }

    try {
      // Check đăng nhập để báo lỗi UI (TaskService cũng check lại 1 lần)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
        return;
      }

      final colorName = TaskConstants.getColorName(
        _colorOptions[_selectedColorIndex].color,
      );
      final task = TaskModel(
        id: '',
        title: _titleController.text.trim(),
        subtitle: _noteController.text.trim(),
        color: _colorOptions[_selectedColorIndex].color,
        colorName: colorName,
        startTime: _startDateTime,
        endTime: _endDateTime,
        priority: _selectedPriority,
        difficulty: _selectedDifficulty,
        groupName: _isGroupMode ? _selectedGroup : '',
        reminders: List<String>.from(_reminders),
        reminderEnabled: _reminderEnabled,
        repeatText: _repeatText,
        repeatEndDate: _repeatEndDate,
        pinned: _pinned,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      await _taskService.addTask(task);

      if (mounted) {
        Navigator.pop(context); // đóng loading
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lưu task thành công')));
        Navigator.of(context).pop(); // quay lại list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // đóng loading nếu đang mở
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
