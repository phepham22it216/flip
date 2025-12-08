import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/models/task_constants.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:flip/features/tasks/widgets/task_edit/color_card.dart';
import 'package:flip/features/tasks/widgets/task_create/repeat_dialog.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/widgets/task_edit/edit_bottom_sheet_header.dart';
import 'package:flip/features/tasks/widgets/task_edit/edit_bottom_sheet_content.dart';
import 'package:flip/features/tasks/widgets/task_edit/add_reminder_dialog.dart';

class TaskEditPage extends StatefulWidget {
  final TaskModel task;

  const TaskEditPage({super.key, required this.task});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
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
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool _reminderEnabled = true;
  final List<String> _reminders = [];

  bool _pinned = false;

  String? _repeatText;
  DateTime? _repeatEndDate;
  // ignore: unused_field
  int? _dailyEvery;
  // ignore: unused_field
  int? _weeklyEvery;
  // ignore: unused_field
  List<bool>? _weekdaySelected;
  // ignore: unused_field
  int? _monthlyDay;
  // ignore: unused_field
  int? _yearlyMonth;
  // ignore: unused_field
  int? _yearlyDay;
  // ignore: unused_field
  int _repeatType = 0; // 0: daily, 1: weekly, 2: monthly, 3: yearly

  int _selectedPriority = 1; // 1: Low, 2: Medium, 3: High
  int _selectedDifficulty = 1; // 1: Easy, 2: Medium, 3: Hard
  bool _isGroupMode = false; // false: Personal, true: Group
  String _selectedGroup = 'Nhóm';

  final List<String> _groups = const ['Nhóm', 'Work', 'Personal', 'Shopping'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.subtitle);
    _startDateTime = widget.task.startTime;
    _endDateTime = widget.task.endTime;

    // Set selected color index based on task color
    _selectedColorIndex = _colorOptions.indexWhere(
      (option) => option.color.value == widget.task.color.value,
    );
    if (_selectedColorIndex == -1) {
      _selectedColorIndex = 0; // Default to first color if not found
    }

    // Initialize reminders from task
    _reminders.addAll(widget.task.reminders);
    _reminderEnabled = widget.task.reminderEnabled;

    // Initialize repeat data from task
    _repeatText = widget.task.repeatText;
    _repeatEndDate = widget.task.repeatEndDate;

    // Initialize pinned state from task
    _pinned = widget.task.pinned;

    // Initialize priority and difficulty from task
    _selectedPriority = widget.task.priority;
    _selectedDifficulty = widget.task.difficulty;
    _selectedGroup = widget.task.groupName.isNotEmpty
        ? widget.task.groupName
        : 'Nhóm';
    _isGroupMode = widget.task.groupName.isNotEmpty;

    // Show edit bottom sheet automatically when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditBottomSheet(context);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: Container());
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      children: [
                        EditBottomSheetHeader(
                          titleController: _titleController,
                          onBackPressed: () => Navigator.pop(context),
                          onCheckPressed: () {
                            _updateTask();
                            Navigator.pop(context);
                          },
                        ),
                        EditBottomSheetContent(
                          noteController: _noteController,
                          allDay: _allDay,
                          startDateTime: _startDateTime,
                          endDateTime: _endDateTime,
                          reminderEnabled: _reminderEnabled,
                          reminders: _reminders,
                          pinned: _pinned,
                          repeatText: _repeatText,
                          repeatEndDate: _repeatEndDate,
                          isGroupMode: _isGroupMode,
                          selectedGroup: _selectedGroup,
                          groups: _groups,
                          selectedPriority: _selectedPriority,
                          selectedDifficulty: _selectedDifficulty,
                          colorOptions: _colorOptions,
                          selectedColorIndex: _selectedColorIndex,
                          onAllDayChanged: () {
                            setModalState(() {
                              setState(() {
                                _allDay = !_allDay;
                                if (_allDay) {
                                  _startDateTime = DateTime(
                                    _startDateTime.year,
                                    _startDateTime.month,
                                    _startDateTime.day,
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
                            });
                          },
                          onStartTap: () => _pickDateTime(
                            isStart: true,
                            setModalState: setModalState,
                          ),
                          onEndTap: () => _pickDateTime(
                            isStart: false,
                            setModalState: setModalState,
                          ),
                          onReminderToggle: () {
                            setModalState(() {
                              setState(
                                () => _reminderEnabled = !_reminderEnabled,
                              );
                            });
                          },
                          onReminderRemove: (index) {
                            setModalState(() {
                              setState(() => _reminders.removeAt(index));
                            });
                          },
                          onAddReminderTap: () =>
                              _showAddReminderOptions(setModalState),
                          onRepeatTap: () =>
                              _showRepeatOptionsDialog(setModalState),
                          onPinnedChanged: () {
                            setModalState(() {
                              setState(() => _pinned = !_pinned);
                            });
                          },
                          onRemoveRepeat: () {
                            setModalState(() {
                              setState(() => _repeatText = null);
                            });
                          },
                          onRemoveRepeatEndDate: () {
                            setModalState(() {
                              setState(() => _repeatEndDate = null);
                            });
                          },
                          onModeChanged: (isGroup) {
                            setModalState(() {
                              setState(() => _isGroupMode = isGroup);
                            });
                          },
                          onGroupChanged: (value) {
                            setModalState(() {
                              setState(() => _selectedGroup = value);
                            });
                          },
                          onPriorityChanged: (priority) {
                            setModalState(() {
                              setState(() => _selectedPriority = priority);
                            });
                          },
                          onDifficultyChanged: (difficulty) {
                            setModalState(() {
                              setState(() => _selectedDifficulty = difficulty);
                            });
                          },
                          onColorSelected: (index) {
                            setModalState(() {
                              setState(() => _selectedColorIndex = index);
                            });
                          },
                          onCustomColor: () {},
                          onUpdatePressed: () {
                            _updateTask();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      Navigator.of(context).pop();
    });
  }

  void _updateTask() async {
    try {
      final colorName = TaskConstants.getColorName(
        _colorOptions[_selectedColorIndex].color,
      );
      final updatedTask = widget.task.copyWith(
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

      await _taskService.updateTask(widget.task.id, updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật mục tiêu thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickDateTime({
    required bool isStart,
    required StateSetter setModalState,
  }) async {
    final current = isStart ? _startDateTime : _endDateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;

    if (_allDay) {
      setModalState(() {
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
    setModalState(() {
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
    });
  }

  Future<void> _showAddReminderOptions(StateSetter setModalState) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AddReminderDialog(
          onReminderSelected: (option) {
            setModalState(() {
              setState(() {
                _reminders.clear();
                _reminders.add(option);
              });
            });
          },
        );
      },
    );
  }

  Future<void> _showRepeatOptionsDialog(StateSetter setModalState) async {
    final result = await showRepeatDialog(context);
    if (result != null) {
      setModalState(() {
        setState(() {
          _repeatText = result.repeatText;
          _repeatEndDate = result.endDate;
          _dailyEvery = result.dailyEvery;
          _weeklyEvery = result.weeklyEvery;
          _weekdaySelected = result.weekdaySelected;
          _monthlyDay = result.monthlyDay;
          _yearlyMonth = result.yearlyMonth;
          _yearlyDay = result.yearlyDay;
          _repeatType = result.repeatType;
        });
      });
    }
  }
}
