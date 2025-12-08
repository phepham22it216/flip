import 'package:flutter/material.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;
  ChartData(this.label, this.value, this.color);
}

class LegendItem {
  final String label;
  final Color color;
  LegendItem(this.label, this.color);
}
