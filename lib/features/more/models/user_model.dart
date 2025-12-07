import 'package:firebase_database/firebase_database.dart';

class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String passwordHash;
  final String? avatarUrl;
  final String? role;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;

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
