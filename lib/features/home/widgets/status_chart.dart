import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';
import '../services/statuschart_service.dart';

class StatusChart extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool, int) onPickDate;

  final StatusChartService _statusService = StatusChartService();

  StatusChart({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
  });

  String format(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    final sDate = startDate ?? today;
    final eDate = endDate ?? tomorrow;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // ⭐ Hàng chọn ngày
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDateBtn("Bắt đầu", () => onPickDate(context, true, 1)),
                const SizedBox(width: 10),
                _buildDateBtn("Kết thúc", () => onPickDate(context, false, 1)),
              ],
            ),

            const SizedBox(height: 8),

            // ⭐ Hàng hiển thị ngày đã chọn
            Text(
              "~ ${format(sDate)} - ${format(eDate)} ~",
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),

            // ⭐ BIỂU ĐỒ + LEGEND
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: FutureBuilder<List<ChartData>>(
                    future: _statusService.calculateStatusPercent(
                      startDate: sDate,
                      endDate: eDate,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!;

                      return SfCircularChart(
                        legend: Legend(isVisible: false),
                        series: [
                          PieSeries<ChartData, String>(
                            dataSource: data,
                            xValueMapper: (item, _) => item.label,
                            yValueMapper: (item, _) => item.value,
                            pointColorMapper: (item, _) => item.color,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                            dataLabelMapper: (item, _) => item.showLabel
                                ? "${item.value.toStringAsFixed(1)}%" // hoặc 2
                                : "",
                          )
                        ],
                      );
                    },
                  ),
                ),

                _buildLegend([
                  LegendItem("Hoàn thành", Colors.green),
                  LegendItem("Chưa xong", Colors.orange),
                  LegendItem("Quá hạn", Colors.red),
                  LegendItem("Không có", Colors.grey),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBtn(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade100,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLegend(List<LegendItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(width: 24, height: 14, color: item.color),
              const SizedBox(width: 8),
              Text(item.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}

