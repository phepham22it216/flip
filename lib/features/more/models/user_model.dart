import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String userId;
  String fullName;
  String email;
  String passwordHash;
  String? avatarUrl;
  String? role;
  String? status;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    this.avatarUrl,
    this.role,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "fullName": fullName,
      "email": email,
      "passwordHash": passwordHash,
      "avatarUrl": avatarUrl ?? "",
      "role": role,
      "status": status,
      "createdAt": ServerValue.timestamp,
      "updatedAt": ServerValue.timestamp,
    };
  }

  /// Convert FireBase ms timestamp to DateTime
  static DateTime _convert(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      userId: map["userId"] ?? "",
      fullName: map["fullName"] ?? "",
      email: map["email"] ?? "",
      passwordHash: map["passwordHash"] ?? "",
      avatarUrl: map["avatarUrl"],
      role: map["role"],
      status: map["status"],
      createdAt: _convert(map["createdAt"]),
      updatedAt: _convert(map["updatedAt"]),
    );
  }
}
