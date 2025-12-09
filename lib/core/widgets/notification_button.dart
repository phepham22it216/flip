import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

import '../models/notify_model.dart';
import '../services/notify_service.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final NotifyService _notifyService = NotifyService();
  List<NotifyModel> _notifications = [];
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();

    // Lắng nghe thông báo từ service
    _notifyService.notificationsStream.listen((notifs) {
      setState(() {
        _notifications = notifs;
        _hasUnread = notifs.any((n) => !n.isRead);
      });
    });
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Thông báo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.xanh3,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        notif.type == "system" ? Colors.blue : Colors.orange,
                        child: Text(
                          notif.type[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        "(${notif.type}) ${notif.title}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(notif.content),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  // Khi xem, badge đỏ biến mất
                  setState(() {
                    _hasUnread = false;
                    for (var n in _notifications) {
                      n.isRead = true;
                    }
                  });
                  Navigator.of(ctx).pop();
                },
                child: const Text("Đóng"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showNotificationsDialog,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.xanh3,
                size: 24,
              ),
            ),
            // Badge đỏ cho thông báo mới
            if (_hasUnread)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.doSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
