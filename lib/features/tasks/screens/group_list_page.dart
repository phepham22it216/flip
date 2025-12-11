// lib/features/tasks/screens/group_list_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip/theme/app_colors.dart';
import '../../tasks/widgets/task_list/quick_action_button.dart';
import '../../tasks/widgets/task_list/action_sheet_button.dart';
import '../../more/models/group_model.dart';
import '../services/group_service.dart';
import 'group_detail_page.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final GroupService _service = GroupService();

  // Controllers for create group form
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _descCtl = TextEditingController();
  final TextEditingController _tagCtl = TextEditingController();
  final TextEditingController _coverCtl = TextEditingController();

  // extra state for create form
  bool _isPrivate = false;
  int _memberLimit = 5;
  String _goal = '';
  String _joinAuth = 'Bất kỳ ai có thể tham gia';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _descCtl.dispose();
    _tagCtl.dispose();
    _coverCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Vui lòng đăng nhập để xem nhóm')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Show only groups that belong to current user -> gọn hơn cho UX
        child: FutureBuilder<List<GroupModel>>(
          future: _service.getUserGroups(user.uid),
          builder: (context, snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // error
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final groups = snapshot.data ?? [];

            // no data
            if (groups.isEmpty) {
              return Column(
                children: [
                  QuickActionButton(incompleteTaskCount: 0, onTap: () {}),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _showJoinByCodeDialog(context),
                      icon: const Icon(Icons.group_add_outlined, size: 18),
                      label: const Text('Join bằng mã'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF39B6F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Center(child: Text('Bạn chưa có nhóm nào')),
                ],
              );
            }

            return Column(
              children: [
                // Quick Action Button
                QuickActionButton(
                  incompleteTaskCount: _countIncomplete(groups),
                  onTap: () {},
                ),

                // small row with Join bằng mã (gọn)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showJoinByCodeDialog(context),
                        icon: const Icon(Icons.group_add_outlined, size: 18),
                        label: const Text('Tham gia bằng mã'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39B6F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Container()),
                    ],
                  ),
                ),

                // content: always show list (no card/calendar/matrix selector)
                Expanded(child: _buildGroupList(groups)),
              ],
            );
          },
        ),
      ),

      // Single FAB: mở form tạo nhóm (gọn)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'groupCreateFab',
        onPressed: () => _showCreateGroupForm(context),
        backgroundColor: AppColors.xanh1,
        child: const Icon(Icons.add, size: 26),
      ),

      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 0,
        child: SizedBox(height: 56),
      ),
    );
  }

  // Dialog shown after creating group to copy/share the group id
  Future<void> _showGroupCreatedDialog(
    BuildContext ctx,
    String groupId,
    String groupName,
  ) async {
    await showDialog(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Tạo nhóm thành công'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tên nhóm: $groupName'),
              const SizedBox(height: 8),
              const Text(
                'Mã Nhóm (ID):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      groupId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: groupId));
                      ScaffoldMessenger.of(dctx).showSnackBar(
                        const SnackBar(content: Text('Đã copy mã nhóm')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Gửi mã này cho người khác để họ nhập tham gia vào nhóm.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: const Text('Đóng'),
            ),
            TextButton(
              onPressed: () {
                final text =
                    'Mời tham gia nhóm "$groupName". Mã nhóm: $groupId';
                Clipboard.setData(ClipboardData(text: text));
                Navigator.of(dctx).pop();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Nội dung chia sẻ đã copy')),
                );
              },
              child: const Text('Sao chép nội dung chia sẻ'),
            ),
          ],
        );
      },
    );
  }

  // ----------------- CREATE GROUP FORM (modal) -----------------
  Future<void> _showCreateGroupForm(BuildContext context) async {
    _nameCtl.clear();
    _descCtl.clear();
    _tagCtl.clear();
    _coverCtl.clear();
    _isPrivate = false;
    _memberLimit = 5;
    _goal = '';
    _joinAuth = 'Bất kỳ ai có thể tham gia';
    setState(() => _isSubmitting = false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            bottom: media.viewInsets.bottom,
            left: 12,
            right: 12,
            top: 16,
          ),
          child: Container(
            height: media.size.height * 0.82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                // header
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A6CD8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        left: 16,
                        right: 16,
                        child: Center(
                          child: Text(
                            'Nhóm Học Tập Mới',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                    ],
                  ),
                ),

                // body
                Expanded(
                  child: StatefulBuilder(
                    builder: (modalCtx, modalSetState) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tên nhóm*',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _nameCtl,
                              decoration: InputDecoration(
                                hintText: 'Tên nhóm',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Nhóm Riêng Tư',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Chỉ những thành viên có mã nhóm mới có thể tham gia',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isPrivate,
                                  onChanged: (v) =>
                                      modalSetState(() => _isPrivate = v),
                                  activeColor: const Color(0xFF8A6CD8),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Mục đích của Nhóm Học Tập*',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () async {
                                final res = await showDialog<String?>(
                                  context: ctx,
                                  builder: (dCtx) {
                                    final tmpCtl = TextEditingController(
                                      text: _goal,
                                    );
                                    return AlertDialog(
                                      title: const Text(
                                        'Chọn / Nhập goal (không dấu cách)',
                                      ),
                                      content: TextField(
                                        controller: tmpCtl,
                                        decoration: const InputDecoration(
                                          hintText: '#english',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dCtx).pop(),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dCtx,
                                          ).pop(tmpCtl.text.trim()),
                                          child: const Text('Chọn'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (res != null)
                                  modalSetState(() => _goal = res);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _goal.isEmpty ? 'ex) #english' : _goal,
                                  style: TextStyle(
                                    color: _goal.isEmpty
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Giới hạn số lượng thành viên',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$_memberLimit',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Container()),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => modalSetState(() {
                                        if (_memberLimit > 2) _memberLimit--;
                                      }),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F0FF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => modalSetState(() {
                                        if (_memberLimit < 50) _memberLimit++;
                                      }),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8A6CD8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            GestureDetector(
                              onTap: () async {
                                final choice =
                                    await showModalBottomSheet<String>(
                                      context: ctx,
                                      builder: (optCtx) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: const Text(
                                                'Bất kỳ ai có thể tham gia',
                                              ),
                                              onTap: () =>
                                                  Navigator.of(optCtx).pop(
                                                    'Bất kỳ ai có thể tham gia',
                                                  ),
                                            ),
                                            ListTile(
                                              title: const Text(
                                                'Yêu cầu phê duyệt',
                                              ),
                                              onTap: () => Navigator.of(
                                                optCtx,
                                              ).pop('Yêu cầu phê duyệt'),
                                            ),
                                            ListTile(
                                              title: const Text('Chỉ mời'),
                                              onTap: () => Navigator.of(
                                                optCtx,
                                              ).pop('Chỉ mời'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                if (choice != null)
                                  modalSetState(() => _joinAuth = choice);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _joinAuth,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _createGroupFromForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A6CD8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createGroupFromForm(BuildContext ctx) async {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên nhóm')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final id = await _service.createGroup(name: name);
      if (id.isNotEmpty && mounted) {
        Navigator.of(ctx).pop();
        await _showGroupCreatedDialog(context, id, name);
        setState(() {});
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(const SnackBar(content: Text('Tạo nhóm thất bại')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text('Tạo nhóm thất bại: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildGroupList(List<GroupModel> groups) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final g = groups[index];
        final summary = _taskSummary(g);
        final color = _cardColor(index);
        final bg = color.withOpacity(0.18);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailPage(groupId: g.id),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.group, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name.isNotEmpty ? g.name : 'Untitled group',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Leader: ${g.leaderUid} • $summary',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _displayRightText(g),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Share mã nhóm',
                              onPressed: () => _shareGroup(g),
                              icon: const Icon(
                                Icons.share,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showGroupActions(context, g),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 6.0),
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareGroup(GroupModel g) async {
    final text = 'Mời tham gia nhóm "${g.name}". Mã nhóm: ${g.id}';
    try {
      await Share.share(text);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nội dung chia sẻ đã copy')),
        );
    }
  }

  void _showGroupActions(BuildContext context, GroupModel g) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionSheetButton(
                    text: 'Sửa',
                    onTap: () {
                      Navigator.pop(ctx);
                      // TODO: edit
                    },
                  ),
                  const Divider(height: 1),
                  ActionSheetButton(
                    text: 'Xóa',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa nhóm này không?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await _service.deleteGroup(g.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa nhóm')),
                            );
                            setState(() {});
                          }
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Xóa thất bại: $e')),
                            );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding + 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ActionSheetButton(
                text: 'Hủy',
                onTap: () => Navigator.pop(ctx),
              ),
            ),
          ],
        );
      },
    );
  }

  int _countIncomplete(List<GroupModel> groups) {
    var total = 0;
    for (final g in groups) {
      if (g.tasks != null && g.tasks.isNotEmpty) {
        for (final t in g.tasks.values) {
          if (t.activity == true && t.isDone == false) total++;
        }
      }
    }
    return total;
  }

  String _taskSummary(GroupModel g) {
    if (g.tasks == null || g.tasks.isEmpty) return 'Chưa có công việc';
    final total = g.tasks.length;
    final done = g.tasks.values.where((t) => t.isDone).length;
    return '$done / $total hoàn thành';
  }

  String _displayRightText(GroupModel g) {
    if (g.tasks == null || g.tasks.isEmpty) return '0';
    final total = g.tasks.length;
    final done = g.tasks.values.where((t) => t.isDone).length;
    final percent = ((done / total) * 100).toInt();
    return '$percent%';
  }

  Color _cardColor(int idx) {
    final list = [
      AppColors.xanh1,
      AppColors.xanh2,
      AppColors.doSoft,
      AppColors.vang,
      AppColors.tim1,
      AppColors.cam,
      AppColors.success,
    ];
    return list[idx % list.length];
  }

  // ---------- Join bằng mã dialog & action ----------
  Future<void> _showJoinByCodeDialog(BuildContext ctx) async {
    final codeCtl = TextEditingController();
    final res = await showDialog<bool>(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Nhập mã nhóm'),
          content: TextField(
            controller: codeCtl,
            decoration: const InputDecoration(hintText: 'Nhập group ID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(true),
              child: const Text('Tham gia'),
            ),
          ],
        );
      },
    );

    if (res != true) return;
    final code = codeCtl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã nhóm')));
      return;
    }

    await _joinGroupByCode(ctx, code);
  }

  Future<void> _joinGroupByCode(BuildContext ctx, String code) async {
    try {
      await _service.joinGroup(code);
      if (!mounted) return;
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Đã tham gia nhóm')));
      setState(() {}); // reload
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        // friendly message on common permission error
        if (msg.contains('PERMISSION_DENIED') ||
            msg.toLowerCase().contains('permission')) {
          msg = 'Không có quyền thực hiện. Kiểm tra Firebase rules.';
        }
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text('Tham gia thất bại: $msg')));
      }
    }
  }
}
