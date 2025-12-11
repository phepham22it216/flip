// lib/features/team/screens/chat_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/group_service.dart';
import '../../more/models/message_model.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  const ChatPage({required this.groupId, super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GroupService _service = GroupService();
  final TextEditingController _controller = TextEditingController();
  final Map<String, MessageModel> _msgsById = {}; // prevent duplicates
  StreamSubscription<DatabaseEvent>? _sub;
  final ScrollController _scrollCtrl = ScrollController();

  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _listen();
    _loadInitial();
  }

  void _listen() {
    final ref = _service.groupRef(widget.groupId).child('chat_messages');
    _sub = ref.onChildAdded.listen(
      (ev) {
        final key = ev.snapshot.key;
        if (key == null) return;
        // if we've already loaded this id from initial load, don't add again
        if (_msgsById.containsKey(key)) return;

        final raw = ev.snapshot.value;
        if (raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          final msg = MessageModel.fromMap(key, map);
          _addMessage(msg);
        }
      },
      onError: (e) {
        debugPrint('chat listen error: $e');
      },
    );
  }

  Future<void> _loadInitial() async {
    try {
      final snap = await _service
          .groupRef(widget.groupId)
          .child('chat_messages')
          .get();
      if (!snap.exists) return;
      final raw = snap.value;
      if (raw is Map) {
        raw.forEach((k, v) {
          try {
            final map = Map<String, dynamic>.from(v);
            final msg = MessageModel.fromMap(k.toString(), map);
            _msgsById[k.toString()] = msg;
          } catch (_) {}
        });
      }

      // after loading, sort and set state
      setState(() {});
      // scroll to bottom after a tiny delay so UI has built
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      debugPrint('loadInitial chat error: $e');
    }
  }

  void _addMessage(MessageModel msg) {
    // msg.id exists (from MessageModel.fromMap)
    _msgsById[msg.id] = msg;
    // keep state updated and scroll to bottom
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    try {
      await _service.sendMessage(widget.groupId, txt);
      _controller.clear();
      // do not optimistic-add here; listener will add the real message with id
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      debugPrint('send message error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gửi thất bại: $e')));
      }
    }
  }

  List<MessageModel> get _sortedMessages {
    final list = _msgsById.values.toList();
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  String _formatTime(MessageModel m) {
    final dt = m.sentAt;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$hh:$mm • $dd/$mo';
  }

  void _scrollToBottom() {
    try {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _sortedMessages;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Chat nhóm',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final m = msgs[index];
                  final isMe = (m.senderId) == _currentUid;
                  final senderName = m.senderId.isNotEmpty ? m.senderId : 'Bạn';
                  final timeText = _formatTime(m);

                  return Container(
                    margin: EdgeInsets.only(
                      top: index == 0 ? 8 : 6,
                      bottom: 6,
                      left: isMe ? 60 : 4,
                      right: isMe ? 4 : 60,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 8),
                            child: Text(
                              senderName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blue.shade600
                                      : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(isMe ? 12 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.content,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          timeText,
                                          style: TextStyle(
                                            color: (isMe
                                                ? Colors.white70
                                                : Colors.grey.shade600),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (isMe)
                                          Icon(
                                            Icons.done_all,
                                            size: 14,
                                            color: isMe
                                                ? Colors.white70
                                                : Colors.grey,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // input area
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_emotions_outlined,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // attach / media action
                            },
                            icon: const Icon(
                              Icons.attach_file,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.blue,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
