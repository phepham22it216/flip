import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/widgets/task_create/title_card.dart';
import 'package:flip/features/tasks/widgets/task_create/schedule_card.dart';
import 'package:flip/features/tasks/widgets/task_create/color_card.dart';
import 'package:flip/features/tasks/services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import model GroupModel (đường dẫn tương tự group_service.dart)
import '../../more/models/group_model.dart';

/// Nếu project bạn có model GroupModel, import nó thay vì định nghĩa tạm dưới đây.
/// import 'package:flip/features/tasks/models/group_model.dart';
class _GroupModelShim {
  final String id;
  final String name;
  _GroupModelShim({required this.id, required this.name});
}

/// Page tạo task cho nhóm  thêm dropdown chọn nhóm (đổ danh sách nhóm của user).
class GroupTaskCreatePage extends StatefulWidget {
  final String groupId;
  const GroupTaskCreatePage({required this.groupId, super.key});

  @override
  State<GroupTaskCreatePage> createState() => _GroupTaskCreatePageState();
}

class _GroupTaskCreatePageState extends State<GroupTaskCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final GroupService _service = GroupService();

  bool _loadingGroups = true;
  List<_GroupModelShim> _groups = [];
  String? _selectedGroupId;

  bool _allDay = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
    _loadUserGroups();
  }

  Future<void> _loadUserGroups() async {
    setState(() => _loadingGroups = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _groups = [];
          _loadingGroups = false;
        });
        return;
      }

      // <-- getUserGroups() trả về List<GroupModel>
      final List<GroupModel> raw = await _service.getUserGroups(user.uid);

      final mapped = raw
          .map(
            (g) => _GroupModelShim(
              id: g.id.toString(),
              name: (g.name ?? 'Nhóm').toString(),
            ),
          )
          .toList();

      setState(() {
        _groups = mapped;

        // chọn group đầu tiên nếu groupId hiện tại không thuộc user
        if (_selectedGroupId == null ||
            !_groups.any((e) => e.id == _selectedGroupId)) {
          _selectedGroupId = _groups.isNotEmpty
              ? _groups.first.id
              : widget.groupId;
        }

        _loadingGroups = false;
      });
    } catch (e) {
      debugPrint("Error loading groups: $e");
      setState(() {
        _groups = [];
        _loadingGroups = false;
      });
    }
  }

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
      appBar: AppBar(
        backgroundColor: AppColors.xanh1,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.white)),
        ),
        title: const Text(
          "Tạo mục tiêu mới",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            // ---------- GROUP SELECT ----------
            _buildGroupSelector(),

            const SizedBox(height: 12),

            TitleCard(
              titleController: _titleController,
              noteController: _noteController,
              onAddSticker: () {},
            ),

            const SizedBox(height: 14),
            ScheduleCard(
              allDay: _allDay,
              startDateTime: _startDate,
              endDateTime: _endDate,
              reminderEnabled: false,
              reminders: const [],
              pinned: false,
              onAllDayChanged: (v) => setState(() => _allDay = v),
              onStartTap: () => _pickDate(true),
              onEndTap: () => _pickDate(false),
              onReminderToggle: (_) {},
              onReminderRemove: (_) {},
              onAddReminderTap: () {},
              onRepeatTap: () {},
              repeatText: null,
              repeatEndDate: null,
              onRemoveRepeat: () {},
              onRemoveRepeatEndDate: () {},
              onPinnedChanged: (_) {},
            ),

            const SizedBox(height: 14),
            ColorCard(
              colorOptions: const [
                TaskColorOption(label: "Xanh", color: AppColors.xanh1),
                TaskColorOption(label: "Tím", color: AppColors.tim1),
                TaskColorOption(label: "Vàng", color: AppColors.vang),
              ],
              selectedIndex: 0,
              onSelect: (_) {},
              onCustomColor: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    if (_loadingGroups) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.group, color: AppColors.xanh1),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đang tải nhóm...',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.group, color: AppColors.xanh1),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bạn chưa có nhóm nào',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                // điều hướng tạo nhóm nếu cần
              },
              child: const Text(
                'Tạo nhóm',
                style: TextStyle(color: AppColors.xanh1),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.group, color: AppColors.xanh1),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedGroupId,
              decoration: const InputDecoration(
                labelText: 'Nhóm',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              items: _groups.map((g) {
                return DropdownMenuItem(value: g.id, child: Text(g.name));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedGroupId = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final result = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) {
      setState(() {
        if (isStart) {
          _startDate = result;
        } else {
          _endDate = result;
        }
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tiêu đề task")),
      );
      return;
    }

    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn nhóm để tạo task")),
      );
      return;
    }

    try {
      await _service.addTask(
        _selectedGroupId!, // <-- dùng nhóm đã chọn
        title: _titleController.text.trim(),
        description: _noteController.text.trim(),
        start: _startDate,
        end: _endDate,
      );
 
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã tạo task trong nhóm")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }
}
