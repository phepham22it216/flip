import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';
import '../services/ratechart_service.dart';

class RateChart extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool, int) onPickDate;

  final RateChartService _rateService = RateChartService();

  RateChart({
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Column(
        children: [
          const Text(
            "- Mức Độ Khó -",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // ⭐ Nút chọn ngày
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateBtn("Bắt đầu", () => onPickDate(context, true, 3)),
              const SizedBox(width: 10),
              _buildDateBtn("Kết thúc", () => onPickDate(context, false, 3)),
            ],
          ),

          const SizedBox(height: 8),

          // ⭐ Hiển thị ngày đã chọn
          Text(
            "~ ${format(sDate)} - ${format(eDate)} ~",
            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 200,
            child: FutureBuilder<List<ChartData>>(
              future: _rateService.calculateDifficultyCount(
                startDate: sDate,
                endDate: eDate,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: [
                    ColumnSeries<ChartData, String>(
                      dataSource: data,   // có thể rỗng!
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      pointColorMapper: (d, _) => d.color,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.middle,
                      ),
                    )
                  ],
                );
              },
            ),
          ),

          _buildLegend(),
        ],
      ),
    );
  }

  // Nút chọn ngày
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

  // Legend
  Widget _buildLegend() {
    return Column(
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            LegendItem("Dễ", Colors.blue),
            LegendItem("Vừa", Colors.purple),
            LegendItem("Khó", Colors.black),
          ].map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 16, height: 16, color: item.color),
                const SizedBox(width: 6),
                Text(item.label),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        const Text(
          "*Số lượng công việc theo mức độ khó!",
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        )
      ],
    );
  }
}