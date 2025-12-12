// lib/features/tasks/screens/group_detail_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip/theme/app_colors.dart';
import '../services/group_service.dart';
import '../../more/models/group_model.dart';
import 'task_status_page.dart';
import 'chat_page.dart';
import 'task_create_page.dart';
import 'group_task_create_page.dart';

class GroupDetailPage extends StatefulWidget { 
  final String groupId;
  const GroupDetailPage({required this.groupId, super.key});
  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final GroupService _service = GroupService();
  GroupModel? _group;
  StreamSubscription<DatabaseEvent>? _sub;
  bool _isLeader = false;

  @override
  void initState() {
    super.initState();
    // lắng nghe realtime từ service
    _sub = _service.listenGroupStream(widget.groupId).listen((ev) {
      final val = ev.snapshot.value;
      if (val == null) {
        setState(() {
          _group = null;
          _isLeader = false;
        });
        return;
      }
      final map = Map<String, dynamic>.from(val as Map);
      final gm = GroupModel.fromMap(widget.groupId, map);
      debugPrint('Group ${gm.id} coverUrl: "${gm.coverUrl}"');

      // xác định xem current user có phải leader không
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final amLeader = (currentUid != null && (gm.leaderUid == currentUid));

      setState(() {
        _group = gm;
        _isLeader = amLeader;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _openCreateTask() async {
    if (_group == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupTaskCreatePage(groupId: _group!.id),
      ),
    );
    // listener realtime sẽ tự cập nhật UI nếu task đã được thêm
  }

  @override
  Widget build(BuildContext context) {
    if (_group == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.xanh1, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tasks = _group!.tasks.values.toList();
    final membersCount = _group!.members.length;
    return Scaffold(
      backgroundColor: Colors.white,
      // header xóa appbar mặc định, làm custom header
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildLeadersNoteCard(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 14)),
            // (Achievement section removed)
            SliverToBoxAdapter(child: const SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMissionCard(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildQuizBanner(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 18)),
            // Tasks section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nhiệm vụ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$membersCount thành viên',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // Tasks list
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final t = tasks[index];
                final doneCount = t.membersDone.keys
                    .where((k) => t.membersDone[k] == true)
                    .length;
                final total = membersCount == 0 ? 1 : membersCount;
                final percent = ((doneCount / total) * 100).toInt();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskStatusPage(
                              groupId: _group!.id,
                              taskId: t.id,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // colored dot
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: t.color ?? AppColors.xanh1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.task_alt,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '$doneCount / $total hoàn thành',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '$percent%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'delete') {
                                  // xóa task nếu cần
                                  await _service.deleteTask(_group!.id, t.id);
                                } else if (v == 'edit') {
                                  // TODO: mở sửa task
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: tasks.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // Floating action button: thêm task (pencil trong circle purple)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.xanh1,
        onPressed: _openCreateTask,
        child: const Icon(Icons.edit, size: 26),
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(groupId: _group!.id),
                  ),
                );
              },
              icon: const Icon(Icons.chat, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            // có thể thêm nút member, settings...
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final coverUrl = _group!.coverUrl?.trim() ?? '';

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Nếu có URL hợp lệ (http/https) -> load network + errorBuilder
          if (coverUrl.isNotEmpty &&
              (coverUrl.startsWith('http') || coverUrl.startsWith('https')))
            Image.network(
              coverUrl,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
              errorBuilder: (ctx, err, stack) {
                // nếu network fail -> show asset fallback
                return Image.asset('assets/images/niel.jpg', fit: BoxFit.cover);
              },
            )
          else
            // Nếu không có URL -> show asset mặc định
            Image.asset('assets/images/niel.jpg', fit: BoxFit.cover),

          // gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // back button and menu
          Positioned(
            left: 6,
            top: 6,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () {},
            ),
          ),

          // group title & tag (bottom-left)
          Positioned(
            left: 16,
            right: 56,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _group!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        _group!.tag.isNotEmpty ? _group!.tag : '#study',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '02:00:00',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.wifi_tethering,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_group!.liveCount ?? 0}/${_group!.liveCapacity ?? 1}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadersNoteCard() {
    final note =
        _group!.leaderNote ?? 'Viết ghi chú để thông báo cho toàn bộ thành viên :)';
    return InkWell(
      onTap: () {
        if (_isLeader) {
          _showEditLeaderNoteDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chỉ leader mới có thể chỉnh sửa note'),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFDB8C2), // pink-ish
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ghi chú của Leader",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.yellow.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Nhiệm vụ hôm nay',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tạo nhiệm vụ và thách thức cùng nhau!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildQuizBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.teal.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Chưa có quiz mới?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tạo quiz và cho mọi người chơi!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // small purple FAB-like circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.create, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditLeaderNoteDialog() async {
    if (_group == null) return;
    final controller = TextEditingController(text: _group!.leaderNote ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Sửa Leader's Note"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Viết ghi chú cho nhóm...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                // nếu muốn cho phép rỗng để xóa note, bỏ validator
                if (v == null || v.trim().isEmpty) {
                  return 'Ghi chú không được rỗng';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final newNote = controller.text.trim();
                Navigator.of(ctx).pop(); // Đóng dialog trước khi lưu
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Đang lưu...')),
                );
                try {
                  await _service.updateLeaderNote(_group!.id, newNote);
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Lưu thành công')),
                  );
                  // listener realtime sẽ cập nhật _group tự động
                } catch (e) {
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(content: Text('Lỗi khi lưu: $e')),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}
