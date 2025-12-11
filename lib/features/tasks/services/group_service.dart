// lib/features/team/services/group_service.dart
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Nếu project của bạn lưu model ở chỗ khác, điều chỉnh đường dẫn import
import '../../more/models/group_model.dart';
import '../../more/models/member_model.dart';
import '../../more/models/message_model.dart';
import 'package:flip/features/tasks/models/task_model.dart';

class GroupService {
  // root reference tới Firebase Realtime Database
  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  // auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GroupService();

  /// Shortcut tới node /groups
  DatabaseReference groupsRef() => _root.child('groups');

  /// Shortcut tới node /groups/{groupId}
  DatabaseReference groupRef(String groupId) => groupsRef().child(groupId);

  /// Lắng nghe realtime cho một group
  Stream<DatabaseEvent> listenGroupStream(String groupId) {
    return groupsRef().child(groupId).onValue;
  }

  /// Tạo group mới (leader = currentUser)
  Future<String> createGroup({required String name}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final newRef = groupsRef().push();
    final groupId = newRef.key!;
    final createdAt = DateTime.now().toIso8601String();

    final data = {
      'id': groupId,
      'name': name,
      'leaderUid': user.uid,
      'createdAt': createdAt,
      'members': {
        user.uid: {
          'uid': user.uid,
          'displayName': user.displayName ?? user.email,
          'role': 'LEADER',
          'joinedAt': createdAt,
        },
      },
      'tasks': {},
      'chat_messages': {},
    };

    await newRef.set(data);
    return groupId;
  }

  /// Thêm member (leader-check server-side client-side)
  Future<void> addMember(
    String groupId,
    String memberUid, {
    String? displayName,
    String role = 'MEMBER',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // simple check leader
    final leaderSnap = await groupsRef().child('$groupId/leaderUid').get();
    if (!leaderSnap.exists || leaderSnap.value != user.uid) {
      throw Exception('Only leader can add members');
    }

    final data = {
      'uid': memberUid,
      'displayName': displayName,
      'role': role,
      'joinedAt': DateTime.now().toIso8601String(),
    };

    await groupsRef().child('$groupId/members/$memberUid').set(data);
  }

  /// Allow current authenticated user to join by groupId (join by code)
  /// If group is private/require-approval you should extend logic accordingly.
  // GroupService: cho phép user tự join bằng mã nhóm
  Future<void> joinGroup(String groupId, {String? displayName}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final memberPath = groupsRef().child('$groupId/members/${user.uid}');
    final data = {
      'uid': user.uid,
      'displayName': displayName ?? (user.displayName ?? user.email),
      'role': 'MEMBER',
      'joinedAt': DateTime.now().toIso8601String(),
    };

    await memberPath.set(data);
  }

  // Thêm vào class GroupService trong group_service.dart

  /// Leader sets (or unsets) done flag for a specific member on a task.
  /// Throws if not authenticated or current user is not the leader.
  Future<void> setMemberDoneByLeader(
    String groupId,
    String taskId,
    String memberUid,
    bool done,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // check leader
    final leaderSnap = await groupsRef().child('$groupId/leaderUid').get();
    if (!leaderSnap.exists || leaderSnap.value != user.uid) {
      throw Exception('Only leader can change other members status');
    }

    final memberPath = '$groupId/tasks/$taskId/membersDone/$memberUid';
    final ref = groupsRef().child(memberPath);

    if (done) {
      await ref.set(true);
    } else {
      await ref.remove();
    }
  }

  /// Member toggles their own done state for a task.
  /// If done==true -> set node, else remove node.
  /// Throws if not member or not authenticated.
  Future<void> toggleOwnDone(String groupId, String taskId, bool done) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // check membership
    final memSnap = await groupsRef()
        .child('$groupId/members/${user.uid}')
        .get();
    if (!memSnap.exists) throw Exception('You are not a member of this group');

    final myPath = '$groupId/tasks/$taskId/membersDone/${user.uid}';
    final ref = groupsRef().child(myPath);

    if (done) {
      await ref.set(true);
    } else {
      await ref.remove();
    }
  }

  Future<void> updateLeaderNote(String groupId, String note) async {
    final DatabaseReference _db = FirebaseDatabase.instance.ref();
    final ref = _db.child('groups').child(groupId).child('leaderNote');
    await ref.set(note);
  }

  /// Set or remove membersDone flag for a given task (leader or the member themself)
  Future<void> setMemberDoneForTask({
    required String groupId,
    required String taskId,
    required String memberUid,
    required bool done,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // check role: allow if leader OR the member themself
    final leaderSnap = await groupsRef().child('$groupId/leaderUid').get();
    final isLeader = leaderSnap.exists && leaderSnap.value == user.uid;
    if (!isLeader && user.uid != memberUid) {
      // not permitted by client logic
      throw Exception(
        'Only leader or the member themself can change this flag',
      );
    }

    final path = groupsRef().child(
      '$groupId/tasks/$taskId/membersDone/$memberUid',
    );
    if (done) {
      await path.set(true);
    } else {
      await path.remove();
    }
  }

  /// Remove member (leader only)
  Future<void> removeMember(String groupId, String memberUid) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final leaderSnap = await groupsRef().child('$groupId/leaderUid').get();
    if (!leaderSnap.exists || leaderSnap.value != user.uid) {
      throw Exception('Only leader can remove members');
    }

    await groupsRef().child('$groupId/members/$memberUid').remove();

    // Optionally clear membersDone flags for all tasks
    final tasksSnap = await groupsRef().child('$groupId/tasks').get();
    if (tasksSnap.exists) {
      final updates = <String, dynamic>{};
      final tasks = Map<dynamic, dynamic>.from(tasksSnap.value as Map);
      tasks.forEach((tId, tData) {
        updates['/groups/$groupId/tasks/$tId/membersDone/$memberUid'] = null;
      });
      if (updates.isNotEmpty) {
        await _root.update(updates);
      }
    }
  }

  /// Thêm task (leader only)
  /// Ghi task vào /groups/{groupId}/tasks/{taskId}
  Future<String> addTask(
    String groupId, {
    required String title,
    String description = '',
    DateTime? start,
    DateTime? end,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final leaderSnap = await groupsRef().child('$groupId/leaderUid').get();
    if (!leaderSnap.exists || leaderSnap.value != user.uid) {
      throw Exception('Only leader can add tasks');
    }

    final newRef = groupsRef().child('$groupId/tasks').push();
    final taskId = newRef.key!;
    final now = DateTime.now().toIso8601String();
    final payload = {
      'id': taskId,
      'title': title,
      'description': description,
      'createdBy': user.uid,
      'createdAt': now,
      'startTime': (start ?? DateTime.now()).millisecondsSinceEpoch,
      'endTime': (end ?? DateTime.now().add(const Duration(hours: 1)))
          .millisecondsSinceEpoch,
      'membersDone': {},
    };
    await newRef.set(payload);
    return taskId;
  }

  /// Member toggle done for themselves
  Future<void> toggleTaskDone(String groupId, String taskId, bool done) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // check membership
    final memSnap = await groupsRef()
        .child('$groupId/members/${user.uid}')
        .get();
    if (!memSnap.exists) throw Exception('You are not a member of this group');

    final path = '$groupId/tasks/$taskId/membersDone/${user.uid}';
    if (done) {
      await groupsRef().child(path).set(true);
    } else {
      await groupsRef().child(path).remove();
    }
  }

  /// Gửi message vào chat của group
  Future<void> sendMessage(String groupId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final memSnap = await groupsRef()
        .child('$groupId/members/${user.uid}')
        .get();
    if (!memSnap.exists) throw Exception('You are not a member of this group');

    final newRef = groupsRef().child('$groupId/chat_messages').push();
    final msg = {
      'id': newRef.key,
      'senderId': user.uid,
      'content': content,
      // prefer storing server timestamp (milliseconds) to ease parsing client-side
      'sentAt': ServerValue.timestamp,
    };
    await newRef.set(msg);
  }

  /// LẤY DANH SÁCH NHÓM MÀ USER THUỘC VỀ (leader hoặc member)
  Future<List<GroupModel>> getUserGroups(String uid) async {
    final snap = await groupsRef().get();
    if (!snap.exists) return [];

    final raw = snap.value;
    if (raw == null) return [];

    final map = Map<dynamic, dynamic>.from(raw as Map);
    final List<GroupModel> out = [];

    map.forEach((key, value) {
      try {
        final v = Map<dynamic, dynamic>.from(value as Map);
        final String id = key.toString();
        final String name = (v['name'] ?? v['title'] ?? 'Nhóm').toString();
        final String? leaderUid = v['leaderUid']?.toString();

        bool isMember = false;
        if (v.containsKey('members') && v['members'] is Map) {
          final members = Map<dynamic, dynamic>.from(v['members'] as Map);
          if (members.containsKey(uid)) isMember = true;
        }

        if (leaderUid == uid || isMember) {
          out.add(GroupModel.fromMap(id, v));
        }
      } catch (e) {
        // ignore malformed entry
      }
    });

    return out;
  }

  /// Lấy tất cả groups (cẩn thận nếu DB quá lớn)
  Future<Map<String, GroupModel>> fetchAllGroups() async {
    final snap = await groupsRef().get();
    if (!snap.exists) return {};
    final map = Map<dynamic, dynamic>.from(snap.value as Map);
    final out = <String, GroupModel>{};
    map.forEach((k, v) {
      out[k.toString()] = GroupModel.fromMap(
        k.toString(),
        Map<dynamic, dynamic>.from(v),
      );
    });
    return out;
  }

  /// Lấy group cụ thể
  Future<GroupModel?> fetchGroup(String groupId) async {
    final snap = await groupsRef().child(groupId).get();
    if (!snap.exists) return null;
    return GroupModel.fromMap(
      groupId,
      Map<dynamic, dynamic>.from(snap.value as Map),
    );
  }

  /// XÓA TASK: xóa node task tại /groups/{groupId}/tasks/{taskId}
  Future<void> deleteTask(String groupId, String taskId) async {
    if (groupId.isEmpty || taskId.isEmpty) {
      throw Exception('groupId hoặc taskId rỗng');
    }

    try {
      final ref = groupsRef().child(groupId).child('tasks').child(taskId);
      await ref.remove();
    } catch (e) {
      rethrow;
    }
  }

  /// Xoá cả group (chỉ leader mới được xoá)
  Future<void> deleteGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Kiểm tra quyền leader
    final leaderSnap = await groupsRef().child('$groupId/leaderUid').get();
    if (!leaderSnap.exists || leaderSnap.value != user.uid) {
      throw Exception('Only leader can delete the group');
    }

    try {
      // Xóa node group (bao gồm members, tasks, chat_messages bên trong)
      await groupsRef().child(groupId).remove();
    } catch (e) {
      throw Exception('Delete group failed: $e');
    }
  }

  /// Lấy danh sách thành viên đã hoàn thành / chưa cho một task
  Future<Map<String, List<MemberModel>>> getTaskMemberStatus(
    String groupId,
    String taskId,
  ) async {
    final groupSnap = await groupsRef().child(groupId).get();
    if (!groupSnap.exists) return {'done': [], 'notDone': []};

    final groupMap = Map<dynamic, dynamic>.from(groupSnap.value as Map);
    final membersMap = groupMap['members'] != null
        ? Map<dynamic, dynamic>.from(groupMap['members'])
        : {};
    final taskMap =
        (groupMap['tasks'] != null && groupMap['tasks'][taskId] != null)
        ? Map<dynamic, dynamic>.from(groupMap['tasks'][taskId])
        : {};
    final membersDone = taskMap['membersDone'] != null
        ? Map<dynamic, dynamic>.from(taskMap['membersDone'])
        : {};

    final done = <MemberModel>[];
    final notDone = <MemberModel>[];

    membersMap.forEach((k, v) {
      final mm = MemberModel.fromMap(
        k.toString(),
        Map<dynamic, dynamic>.from(v),
      );
      if (membersDone[k] == true)
        done.add(mm);
      else
        notDone.add(mm);
    });

    return {'done': done, 'notDone': notDone};
  }
}
