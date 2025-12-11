import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySegmentedControl extends StatefulWidget {
  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int> onChanged;

  const MySegmentedControl({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    required this.onChanged,
  });

  @override
  State<MySegmentedControl> createState() => _MySegmentedControlState();
}

class _MySegmentedControlState extends State<MySegmentedControl> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final children = <int, Widget>{
      for (int i = 0; i < widget.tabs.length; i++)
        i: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Text(
            widget.tabs[i],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _current == i ? Colors.white : Colors.black87,
            ),
          ),
        ),
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: CupertinoSegmentedControl<int>(
        groupValue: _current,
        children: children,
        borderColor: Colors.transparent,
        selectedColor: const Color(0xff0092ff),
        unselectedColor: Colors.transparent,
        pressedColor: const Color(0xff0092ff).withOpacity(0.2),
        onValueChanged: (value) {
          setState(() => _current = value);
          widget.onChanged(value);
        },
      ),
    );
  }
}
