import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class UserDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref("users");

  Future<void> saveUser(UserModel user) async {
    await _db.child(user.userId).set(user.toMap());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    data["updatedAt"] = ServerValue.timestamp;
    await _db.child(userId).update(data);
  }

  Future<UserModel?> getUser(String userId) async {
    final snapshot = await _db.child(userId).get();
    if (!snapshot.exists) return null;

    return UserModel.fromMap(snapshot.value as Map);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot =
    await _db.orderByChild("email").equalTo(email).get();

    if (!snapshot.exists) return null;

    return UserModel.fromMap(snapshot.children.first.value as Map);
  }
}
