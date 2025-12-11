// lib/features/team/models/group_model.dart
import 'package:flip/features/tasks/models/task_model.dart';
import 'member_model.dart';
import 'message_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String leaderUid;
  final DateTime createdAt;

  // optional fields cho UI
  final String coverUrl; // url ảnh header
  final String tag; // ví dụ '#study'
  final String leaderNote;
  final int liveCount;
  final int liveCapacity;

  final Map<String, MemberModel> members;
  final Map<String, TaskModel> tasks;
  final Map<String, MessageModel> chatMessages;

  GroupModel({
    required this.id,
    required this.name,
    required this.leaderUid,
    required this.createdAt,
    this.coverUrl = '',
    this.tag = '',
    this.leaderNote = '',
    this.liveCount = 0,
    this.liveCapacity = 1,
    this.members = const {},
    this.tasks = const {},
    this.chatMessages = const {},
  });

  factory GroupModel.fromMap(String id, Map<dynamic, dynamic> map) {
    DateTime parseCreated(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // parse members
    final members = <String, MemberModel>{};
    if (map['members'] != null) {
      try {
        final m = Map<dynamic, dynamic>.from(map['members']);
        m.forEach((k, v) {
          try {
            members[k.toString()] = MemberModel.fromMap(
              k.toString(),
              Map<dynamic, dynamic>.from(v),
            );
          } catch (_) {
            // skip malformed member entry
          }
        });
      } catch (_) {
        // ignore
      }
    }

    // parse tasks -> convert each to TaskModel using your TaskModel.fromMap(rawMap, id)
    final tasks = <String, TaskModel>{};
    if (map['tasks'] != null) {
      try {
        final t = Map<dynamic, dynamic>.from(map['tasks']);
        t.forEach((k, v) {
          try {
            final raw = Map<String, dynamic>.from(
              Map<dynamic, dynamic>.from(
                v,
              ).map((key, value) => MapEntry(key.toString(), value)),
            );
            tasks[k.toString()] = TaskModel.fromMap(raw, k.toString());
          } catch (_) {
            // skip malformed task
          }
        });
      } catch (_) {
        // ignore
      }
    }

    // parse chat messages
    final chats = <String, MessageModel>{};
    if (map['chat_messages'] != null || map['chatMessages'] != null) {
      final src = map['chat_messages'] ?? map['chatMessages'];
      try {
        final c = Map<dynamic, dynamic>.from(src);
        c.forEach((k, v) {
          try {
            chats[k.toString()] = MessageModel.fromMap(
              k.toString(),
              Map<dynamic, dynamic>.from(v),
            );
          } catch (_) {
            // skip
          }
        });
      } catch (_) {
        // ignore
      }
    }

    // helpers to safely read string/int fields with fallback names
    String readString(dynamic key, [String fallback = '']) {
      try {
        final val = map[key];
        if (val == null) return fallback;
        return val.toString();
      } catch (_) {
        return fallback;
      }
    }

    int readInt(dynamic key, [int fallback = 0]) {
      try {
        final val = map[key];
        if (val == null) return fallback;
        if (val is int) return val;
        if (val is String) return int.tryParse(val) ?? fallback;
        if (val is double) return val.toInt();
        return fallback;
      } catch (_) {
        return fallback;
      }
    }

    return GroupModel(
      id: id,
      name: readString('name', ''),
      leaderUid: readString('leaderUid', readString('leader', '')),
      createdAt: parseCreated(
        map['createdAt'] ?? map['created_at'] ?? map['createdAtMillis'],
      ),
      coverUrl: readString('coverUrl', readString('cover', '')),
      tag: readString('tag', readString('goal', '')),
      leaderNote: readString('leaderNote', readString('note', '')),
      liveCount: readInt('liveCount', readInt('live_count', 0)),
      liveCapacity: readInt('liveCapacity', readInt('live_capacity', 1)),
      members: members,
      tasks: tasks,
      chatMessages: chats,
    );
  }

  Map<String, dynamic> toMap() {
    final membersMap = <String, dynamic>{};
    members.forEach((k, v) => membersMap[k] = v.toMap());

    final tasksMap = <String, dynamic>{};
    tasks.forEach((k, v) => tasksMap[k] = v.toMap());

    final chatsMap = <String, dynamic>{};
    chatMessages.forEach((k, v) => chatsMap[k] = v.toMap());

    return {
      'name': name,
      'leaderUid': leaderUid,
      'createdAt': createdAt.toIso8601String(),
      'coverUrl': coverUrl,
      'tag': tag,
      'leaderNote': leaderNote,
      'liveCount': liveCount,
      'liveCapacity': liveCapacity,
      'members': membersMap,
      'tasks': tasksMap,
      'chat_messages': chatsMap,
    };
  }

  // convenience getters
  int get membersCount => members.length;
  int get tasksCount => tasks.length;
}
