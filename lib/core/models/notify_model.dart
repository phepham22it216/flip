class NotifyModel {
  final String notificationId;
  final String title;
  final String content;
  final String type; // system / prediction
  final String? taskId;
  bool isRead;
  final DateTime createdAt;

  NotifyModel({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.type,
    this.taskId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotifyModel.fromMap(Map<String, dynamic> map) {
    return NotifyModel(
      notificationId: map['notificationId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'system',
      taskId: map['taskId'],
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "notificationId": notificationId,
      "title": title,
      "content": content,
      "type": type,
      "taskId": taskId,
      "isRead": isRead,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
