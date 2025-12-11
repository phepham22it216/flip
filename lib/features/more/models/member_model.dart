// lib/features/team/models/member_model.dart
class MemberModel {
  final String uid;
  final String? displayName;
  final String role; // "LEADER" | "MEMBER"
  final DateTime joinedAt;

  MemberModel({
    required this.uid,
    this.displayName,
    required this.role,
    required this.joinedAt,
  });

  factory MemberModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    final joined = map['joinedAt'];
    DateTime parse(dynamic v) {
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

    return MemberModel(
      uid: uid,
      displayName:
          (map['displayName'] as String?) ?? (map['fullName'] as String?),
      role:
          (map['role'] as String?) ??
          (map['roleInGroup'] as String?) ??
          'MEMBER',
      joinedAt: parse(joined ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'displayName': displayName,
    'role': role,
    'joinedAt': joinedAt.toIso8601String(),
  };
}
