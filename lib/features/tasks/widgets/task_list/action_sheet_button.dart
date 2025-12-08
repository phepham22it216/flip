import 'package:flutter/material.dart';

class ActionSheetButton extends StatelessWidget {
  final String text;
  final bool isDestructive;
  final VoidCallback onTap;

  const ActionSheetButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.blue,
          ),
        ),
      ),
    );
  }
}
