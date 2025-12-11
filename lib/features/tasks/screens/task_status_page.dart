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
      // load group to check leader
      final group = await _service.fetchGroup(widget.groupId);
      _isLeader = group?.leaderUid == _currentUid;

      // load members status via helper in service (returns done/notDone lists)
      final status = await _service.getTaskMemberStatus(
        widget.groupId,
        widget.taskId,
      );
      final d = status['done'] ?? <MemberModel>[];
      final n = status['notDone'] ?? <MemberModel>[];

      // ensure current user appears in one of lists
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
        // toggle own
        await _service.toggleOwnDone(widget.groupId, widget.taskId, targetDone);
      } else {
        // only leader can toggle others
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
              // tap toggles if allowed
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
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: accent,
                  child: Text(
                    list.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                if (title == 'Member not done' && _isLeader)
                  TextButton.icon(
                    onPressed: list.isEmpty
                        ? null
                        : () async {
                            // leader mark all done
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Xác nhận'),
                                content: Text(
                                  'Leader sẽ đánh dấu ${list.length} thành viên là đã xong. Tiếp tục?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx, true),
                                    child: const Text('OK'),
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
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark all'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (list.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    title == 'Member done'
                        ? 'Chưa ai hoàn thành'
                        : 'Không có thành viên cần hoàn thành',
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 6),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final m = list[idx];
                    return _buildMemberTile(m, title == 'Member done');
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumn(
                          'Member done',
                          done,
                          accent: AppColors.success,
                        ),
                        _buildColumn(
                          'Member not done',
                          notDone,
                          accent: AppColors.xanh1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // saving overlay
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
