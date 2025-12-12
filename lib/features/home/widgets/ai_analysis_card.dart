import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AIAnalysisCard extends StatelessWidget {
  final String userId;
  const AIAnalysisCard({super.key, required this.userId});

  /// Lắng nghe Firebase realtime
  Stream<Map<String, dynamic>> _listen(String uid) {
    final ref = FirebaseDatabase.instance.ref('aiAnalysis/$uid');
    debugPrint('[AIAnalysisCard] subscribe to path: aiAnalysis/$uid');
    return ref.onValue.map((event) {
      final v = event.snapshot.value;
      debugPrint('[AIAnalysisCard] snapshot for $uid -> ${v.runtimeType}');
      // nếu null trả map rỗng
      if (v == null) return <String, dynamic>{};
      // nếu đã là Map thì convert an toàn
      if (v is Map) {
        try {
          return Map<String, dynamic>.from(v);
        } catch (e) {
          debugPrint('[AIAnalysisCard] convert Map error: $e');
          // cố gắng ép từng entry
          final out = <String, dynamic>{};
          (v as Map).forEach((k, val) => out['$k'] = val);
          return out;
        }
      }
      // nếu string JSON? (thường không) --> trả raw
      return <String, dynamic>{'raw': v.toString()};
    });
  }

  Widget _buildLoading() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Đang tải phân tích..."),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(List items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((e) {
        final t = e?.toString() ?? "";
        return Chip(
          backgroundColor: color.withOpacity(.12),
          label: Text(t, style: TextStyle(color: color)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1976D2);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _listen(userId),
      builder: (context, snap) {
        // debug nhanh
        debugPrint(
          '[AIAnalysisCard] builder snapshot.hasData=${snap.hasData} error=${snap.error}',
        );

        if (snap.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Lỗi khi đọc dữ liệu AI: ${snap.error}'),
            ),
          );
        }

        if (!snap.hasData) return _buildLoading();

        final data = snap.data ?? {};

        // nếu rỗng => loading (tương tự trước)
        if (data.isEmpty) return _buildLoading();

        // nếu server trả error field
        if (data["error"] != null && data["error"] != "ok") {
          debugPrint('[AIAnalysisCard] server error: ${data["error"]}');
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "⚠ AI chưa thể phân tích:\n${data["error"]}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // Nếu chỉ có raw text trả về (AI chưa parse JSON)
        if ((data["assessment"] == null) &&
            (data["metrics"] == null) &&
            (data["strengths"] == null) &&
            data["raw"] != null) {
          final raw = data["raw"].toString();
          debugPrint(
            '[AIAnalysisCard] raw received: ${raw.substring(0, raw.length > 120 ? 120 : raw.length)}...',
          );
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI trả về (chưa parse JSON):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(raw),
                ],
              ),
            ),
          );
        }

        // Nếu đã parse
        final metrics = Map<String, dynamic>.from(data["metrics"] ?? {});
        final total = metrics["total"] is num
            ? (metrics["total"] as num).toInt()
            : int.tryParse('${metrics["total"]}') ?? 0;
        final unread = metrics["unread"] is num
            ? (metrics["unread"] as num).toInt()
            : int.tryParse('${metrics["unread"]}') ?? 0;

        double ratio = 0;
        try {
          final r = metrics["unread_ratio"] ?? metrics["unreadRatio"] ?? 0;
          ratio = (r is num)
              ? r.toDouble()
              : double.tryParse(r.toString()) ?? 0.0;
        } catch (_) {
          ratio = 0.0;
        }
        ratio = ratio.clamp(0.0, 1.0);

        final assessment = data["assessment"]?.toString() ?? "";
        final strengths = List.from(data["strengths"] ?? []);
        final weaknesses = List.from(data["weaknesses"] ?? []);
        final recommendations = List.from(data["recommendations"] ?? []);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Phân tích AI",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text("Tổng: $total"),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    const SizedBox(width: 6),
                    Chip(
                      label: Text("Chưa đọc: $unread"),
                      backgroundColor: Colors.orange.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (1 - ratio).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        color: ratio < .3
                            ? Colors.green
                            : (ratio < .6 ? Colors.orange : Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("${(100 * (1 - ratio)).round()}%"),
                  ],
                ),
                const SizedBox(height: 16),
                if (assessment.isNotEmpty) ...[
                  const Text(
                    "Đánh giá:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(assessment),
                  const SizedBox(height: 16),
                ],
                if (strengths.isNotEmpty) ...[
                  const Text(
                    "Điểm mạnh",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildChips(strengths, Colors.green),
                  const SizedBox(height: 16),
                ],
                if (weaknesses.isNotEmpty) ...[
                  const Text(
                    "Điểm yếu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildChips(weaknesses, Colors.red),
                  const SizedBox(height: 16),
                ],
                if (recommendations.isNotEmpty) ...[
                  const Text(
                    "Khuyến nghị ưu tiên",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recommendations.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${e.key + 1}. ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: Text(e.value.toString())),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
