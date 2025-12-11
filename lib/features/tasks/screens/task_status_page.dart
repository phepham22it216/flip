// lib/features/team/screens/task_status_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../more/models/member_model.dart';
import '../services/group_service.dart';
import 'package:flip/theme/app_colors.dart';

class TaskStatusPage extends StatefulWidget {
  final String groupId;
  final String taskId;
  const TaskStatusPage({
    required this.groupId,
    required this.taskId,
    super.key,
  });

  @override
  State<TaskStatusPage> createState() => _TaskStatusPageState();
}

class _TaskStatusPageState extends State<TaskStatusPage> {
  final GroupService _service = GroupService();
  List<MemberModel> done = [], notDone = [];
  bool _loading = true;
  bool _saving = false;
  String? _currentUid;
  bool _isLeader = false;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
    });
    try {
      // tải nhóm để kiểm tra leader
      final group = await _service.fetchGroup(widget.groupId);
      _isLeader = group?.leaderUid == _currentUid;

      // tải trạng thái thành viên (trả về danh sách done/notDone)
      final status = await _service.getTaskMemberStatus(
        widget.groupId,
        widget.taskId,
      );
      final d = status['done'] ?? <MemberModel>[];
      final n = status['notDone'] ?? <MemberModel>[];

      // đảm bảo người dùng hiện tại xuất hiện trong một danh sách
      setState(() {
        done = List<MemberModel>.from(d);
        notDone = List<MemberModel>.from(n);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tải trạng thái thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatJoined(MemberModel m) {
    final dynamic raw = m.joinedAt;
    if (raw == null) return '';

    DateTime? dt;

    if (raw is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      dt = DateTime.tryParse(raw);
    }

    if (dt == null) return '';

    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  Future<void> _toggleMember(MemberModel m, bool targetDone) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final isSelf = m.uid == _currentUid;
      if (isSelf) {
        // chuyển đổi của chính mình
        await _service.toggleOwnDone(widget.groupId, widget.taskId, targetDone);
      } else {
        // chỉ leader mới có thể chuyển đổi thành viên khác
        if (!_isLeader) {
          throw Exception(
            'Chỉ leader mới có quyền thay đổi trạng thái thành viên khác',
          );
        }
        await _service.setMemberDoneByLeader(
          widget.groupId,
          widget.taskId,
          m.uid,
          targetDone,
        );
      }
      await _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildMemberTile(MemberModel m, bool isDone) {
    final display = (m.displayName ?? '').isNotEmpty ? m.displayName! : m.uid;

    final subtitle = (m.joinedAt != null)
        ? 'Tham gia: ${_formatJoined(m)}'
        : '';

    final isSelf = m.uid == _currentUid;
    final canToggle = isSelf || _isLeader;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.xanh1,
        child: Text(
          display.isNotEmpty ? display[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(display, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: canToggle
          ? Checkbox(
              value: isDone,
              onChanged: (v) {
                if (v == null) return;
                _toggleMember(m, v);
              },
            )
          : Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppColors.success : Colors.grey.shade400,
            ),
      onTap: canToggle
          ? () {
              // nhấn để chuyển đổi nếu được phép
              _toggleMember(m, !isDone);
            }
          : null,
    );
  }

  Widget _buildColumn(
    String title,
    List<MemberModel> list, {
    required Color accent,
  }) {
    final isNotDone = title == 'Chưa Hoàn Thành';
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            // Header với tiêu đề và số lượng
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: accent,
                    child: Text(
                      list.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Nút "Đánh dấu tất cả" (chỉ cho leader ở cột "Chưa Hoàn Thành")
            if (isNotDone && _isLeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: list.isEmpty
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Xác nhận'),
                                content: Text(
                                  'Đánh dấu ${list.length} thành viên là đã hoàn thành?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx, true),
                                    child: const Text('Xác nhận'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              setState(() => _saving = true);
                              try {
                                for (final m in list) {
                                  await _service.setMemberDoneByLeader(
                                    widget.groupId,
                                    widget.taskId,
                                    m.uid,
                                    true,
                                  );
                                }
                                await _loadAll();
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: $e')),
                                  );
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            }
                          },
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Đánh dấu tất cả'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            
            // Danh sách thành viên
            if (list.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    isNotDone ? 'Tất cả đã hoàn thành' : 'Chưa ai hoàn thành',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, idx) {
                    final m = list[idx];
                    return _buildMemberTile(m, !isNotDone);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trạng thái chi tiết'),
        backgroundColor: AppColors.xanh1,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              RefreshIndicator(
                onRefresh: _loadAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        48,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildColumn(
                          'Đã Hoàn Thành',
                          done,
                          accent: AppColors.success,
                        ),
                        _buildColumn(
                          'Chưa Hoàn Thành',
                          notDone,
                          accent: AppColors.xanh1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // lớp phủ khi đang lưu
            if (_saving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.18),
                  child: const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
