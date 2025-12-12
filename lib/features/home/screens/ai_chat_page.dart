// <paste thay thế toàn bộ file AIChatPage bằng đoạn này>
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../services/ai_chat_service.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final db = FirebaseDatabase.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  bool _sending = false;
  bool _awaitingAI = false;
  int _lastAiTimestamp = 0;
  StreamSubscription<DatabaseEvent>? _sub;

  @override
  void initState() {
    super.initState();

    // IMPORTANT: listen input changes so button enable/disable cập nhật realtime
    _controller.addListener(() {
      // small optimization: only call setState when mounted
      if (mounted) setState(() {});
    });

    if (uid != null) {
      // Listen for AI replies (child added)
      _sub = db
          .ref('aiChat/$uid')
          .onChildAdded
          .listen(
            (ev) {
              final v = ev.snapshot.value;
              if (v is Map && (v['role'] == 'ai' || v['role'] == 'assistant')) {
                final t = (v['time'] is int)
                    ? v['time'] as int
                    : int.tryParse('${v['time']}') ?? 0;
                if (t > _lastAiTimestamp) {
                  if (mounted) {
                    setState(() {
                      _awaitingAI = false;
                      _lastAiTimestamp = t;
                    });
                  }
                  Future.delayed(
                    const Duration(milliseconds: 120),
                    _scrollToBottom,
                  );
                }
              }
            },
            onError: (err) {
              // debug listener errors
              debugPrint('AI childAdded listener error: $err');
            },
          );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(() {}); // safe no-op
    _controller.dispose();
    _scroll.dispose();
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    if (!_scroll.hasClients) return;
    try {
      await _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  String _formatTime(int ms) {
    if (ms <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || uid == null) {
      // nothing to send or not logged in
      if (uid == null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập')));
      }
      return;
    }

    setState(() {
      _sending = true;
    });

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      debugPrint('Gửi message: $text');

      // 1) push user message
      final userRef = db.ref('aiChat/$uid').push();
      await userRef.set({'role': 'user', 'text': text, 'time': now});

      // 2) set awaiting state
      if (mounted) {
        _controller.clear();
        setState(() {
          _awaitingAI = true;
        });
      }

      // 3) notify backend (n8n) to process — may throw if network/rules fail
      await AIChatService().sendUserMessage(uid!, text);

      // don't await reply - stream listener will handle AI reply when ready
    } catch (e, st) {
      debugPrint('Lỗi khi gửi: $e\n$st');

      // show user-friendly message + hint if permission denied
      final errStr = e.toString();
      final userMsg = errStr.contains('permission-denied')
          ? 'Quyền truy cập DB bị từ chối (permission-denied). Kiểm tra rules.'
          : 'Gửi thất bại: $errStr';

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userMsg)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
      Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
    }
  }

  Widget _buildMessageBubble(Map msg) {
    final role = (msg['role'] ?? 'user').toString();
    final text = (msg['text'] ?? '').toString();
    final timeVal = msg['time'] is int
        ? msg['time'] as int
        : int.tryParse('${msg['time']}') ?? 0;
    final isUser = role == 'user';

    final bubbleColor = isUser ? const Color(0xFF4B89D1) : Colors.grey.shade100;
    final textColor = isUser ? Colors.white : Colors.black87;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final avatar = isUser
        ? const CircleAvatar(
            child: Icon(Icons.person, color: Colors.white),
            backgroundColor: Color(0xFF2B6CB0),
          )
        : const CircleAvatar(
            child: Icon(Icons.smart_toy, color: Colors.white),
            backgroundColor: Color(0xFF555555),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Padding(padding: const EdgeInsets.only(right: 8), child: avatar),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 540),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 12 : 4),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isUser ? 12 : 12),
                      bottomRight: Radius.circular(isUser ? 4 : 12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(timeVal),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8), avatar],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trợ lý AI')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn chưa đăng nhập', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    final ref = db.ref('aiChat/$uid');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Color(0xFF1976D2),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Trợ lý AI - Quản lý công việc')),
          ],
        ),
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Messages list
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: ref.orderByChild('time').onValue,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Lỗi stream: ${snap.error}'));
                    }
                    if (!snap.hasData || snap.data!.snapshot.value == null) {
                      return const Center(
                        child: Text(
                          'Chưa có tin nhắn. Hãy gửi câu hỏi cho trợ lý nhé!',
                        ),
                      );
                    }

                    final map = snap.data!.snapshot.value;
                    Map<String, dynamic> typed = {};
                    if (map is Map) {
                      map.forEach((k, v) => typed['$k'] = v);
                    }

                    final msgs =
                        typed.entries.map((e) {
                          final m = Map<String, dynamic>.from(e.value as Map);
                          m['__key'] = e.key;
                          return m;
                        }).toList()..sort((a, b) {
                          final ta = a['time'] is int
                              ? a['time'] as int
                              : int.tryParse('${a['time']}') ?? 0;
                          final tb = b['time'] is int
                              ? b['time'] as int
                              : int.tryParse('${b['time']}') ?? 0;
                          return ta.compareTo(tb);
                        });

                    if (msgs.isNotEmpty) {
                      final lastAi = msgs.reversed.firstWhere(
                        (m) => m['role'] == 'ai' || m['role'] == 'assistant',
                        orElse: () => <String, dynamic>{},
                      );
                      if (lastAi.isNotEmpty) {
                        final t = lastAi['time'] is int
                            ? lastAi['time'] as int
                            : int.tryParse('${lastAi['time']}') ?? 0;
                        if (t > _lastAiTimestamp) _lastAiTimestamp = t;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ListView.builder(
                        controller: _scroll,
                        itemCount: msgs.length + (_awaitingAI ? 1 : 0),
                        itemBuilder: (context, idx) {
                          if (idx == msgs.length && _awaitingAI) {
                            // typing indicator (AI)
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFF555555),
                                    child: Icon(
                                      Icons.smart_toy,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        SizedBox(
                                          width: 6,
                                          height: 6,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        SizedBox(
                                          width: 6,
                                          height: 6,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        SizedBox(
                                          width: 6,
                                          height: 6,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final m = msgs[idx];
                          return _buildMessageBubble(m);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  hintText: 'Hỏi trợ lý: "Hôm nay nên làm gì?"',
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  (_sending || _controller.text.trim().isEmpty)
                                  ? null
                                  : _sendMessage,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Color(0xFF1976D2),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
