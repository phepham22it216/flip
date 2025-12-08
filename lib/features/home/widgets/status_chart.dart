import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';

class StatusChart extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool, int) onPickDate;

  const StatusChart({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // ⭐ Nút chọn ngày — nằm trên đầu biểu đồ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDateBtn("Bắt đầu", () => onPickDate(context, true, 1)),
                const SizedBox(width: 10),
                _buildDateBtn("Kết thúc", () => onPickDate(context, false, 1)),
              ],
            ),

            //const SizedBox(height: 10),

            // ⭐ 2 bên: biểu đồ + legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: SfCircularChart(
                    legend: Legend(isVisible: false),
                    series: <PieSeries<ChartData, String>>[
                      PieSeries<ChartData, String>(
                        dataSource: [
                          ChartData('Done', 40, Colors.green),
                          ChartData('Pending', 30, Colors.orange),
                          ChartData('Overdue', 30, Colors.red),
                        ],
                        xValueMapper: (data, _) => data.label,
                        yValueMapper: (data, _) => data.value,
                        pointColorMapper: (data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),

                //const SizedBox(width: 2),

                _buildLegend([
                  LegendItem("Hoàn thành", Colors.green),
                  LegendItem("Chưa xong", Colors.orange),
                  LegendItem("Quá hạn", Colors.red),
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

  // ⭐ Legend nằm dọc nhưng nhỏ gọn và đặt cạnh biểu đồ
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
