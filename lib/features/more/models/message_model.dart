// lib/features/team/models/message_model.dart

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
  });

  /// Parse value => DateTime
  static DateTime _parseTimestamp(dynamic v) {
    if (v == null) return DateTime.now();

    // Firebase timestamp (milliseconds)
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }

    // ISO string / normal string
    if (v is String) {
      final millis = int.tryParse(v);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
      try {
        return DateTime.parse(v);
      } catch (_) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MessageModel(
      id: id,
      senderId:
          (map['senderId'] as String?) ?? (map['userId'] as String?) ?? '',

      content: (map['content'] as String?) ?? '',

      // ưu tiên sentAt -> createdAt -> timestamp
      sentAt: _parseTimestamp(
        map['sentAt'] ?? map['createdAt'] ?? map['timestamp'],
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'content': content,
    'sentAt': sentAt.millisecondsSinceEpoch, // luôn lưu dạng int cho Firebase
  };
}
