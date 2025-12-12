import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class AIAnalysisService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Stream dữ liệu phân tích cho userId
  Stream<Map<String, dynamic>> listenUserAIAnalysis(String userId) {
    final ref = _db.child('aiAnalysis').child(userId);
    return ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <String, dynamic>{};
      if (val is Map) {
        return Map<String, dynamic>.from(val as Map);
      }
      // nếu dạng JSON string, parse nếu cần
      return <String, dynamic>{};
    });
  }
}
