import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/widgets/task_edit/color_card.dart';
import 'package:flip/features/tasks/widgets/task_edit/schedule_card.dart';
import 'package:flip/features/tasks/widgets/task_create/repeat_dialog.dart';
import 'package:flip/theme/app_colors.dart';

class TaskEditPage extends StatefulWidget {
  final TaskModel task;

  const TaskEditPage({super.key, required this.task});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;

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
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Header with back arrow, title, and checkmark
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 24),
                                onPressed: () {
                                  Navigator.pop(context); // Close bottom sheet
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _titleController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Tiêu đề',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  size: 24,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  _saveTask();
                                  Navigator.pop(context); // Close bottom sheet
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTitleCard(),
                        const SizedBox(height: 14),
                        ScheduleCard(
                          allDay: _allDay,
                          startDateTime: _startDateTime,
                          endDateTime: _endDateTime,
                          reminderEnabled: _reminderEnabled,
                          reminders: _reminders,
                          pinned: _pinned,
                          onAllDayChanged: (value) {
                            setModalState(() {
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
                          onReminderToggle: (value) {
                            setModalState(() {
                              setState(() => _reminderEnabled = value);
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
                          onPinnedChanged: (value) {
                            setModalState(() {
                              setState(() => _pinned = value);
                            });
                          },
                          repeatText: _repeatText,
                          repeatEndDate: _repeatEndDate,
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
                        ),
                        const SizedBox(height: 14),
                        ColorCard(
                          colorOptions: _colorOptions,
                          selectedIndex: _selectedColorIndex,
                          onSelect: (index) {
                            setModalState(() {
                              setState(() => _selectedColorIndex = index);
                            });
                          },
                          onCustomColor: () {},
                        ),
                        const SizedBox(height: 24),
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
      // Navigate back when bottom sheet is closed
      Navigator.of(context).pop();
    });
  }

  void _saveTask() {
    // TODO: Implement save logic here
    // You can update the task with new values and save to database/state management

    // Show success message after bottom sheet is closed
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật mục tiêu thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
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
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Thêm chi tiết',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
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
                      'Thời gian nhắc nhở ',
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
                        setModalState(() {
                          setState(() {
                            _reminders.clear();
                            _reminders.add(option);
                          });
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
