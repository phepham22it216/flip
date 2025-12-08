import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';
import '../services/importantchart_service.dart';

class ImportantChart extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool, int) onPickDate;

  final ImportantChartService _service = ImportantChartService();

  ImportantChart({
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
            "- Mức Độ Quan Trọng -",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // ⭐ Hàng chọn ngày
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateBtn(context, "Bắt đầu", () => onPickDate(context, true, 2)),
              const SizedBox(width: 10),
              _buildDateBtn(context, "Kết thúc", () => onPickDate(context, false, 2)),
            ],
          ),

          const SizedBox(height: 8),

          // ⭐ Hàng hiển thị ngày đã chọn
          Text(
            "~ ${format(sDate)} - ${format(eDate)} ~",
            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 10),

          // ⭐ BIỂU ĐỒ
          SizedBox(
            height: 200,
            child: FutureBuilder<Map<String, int>>(
              future: _service.calculatePriorityCount(
                startDate: sDate,
                endDate: eDate,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final counts = snapshot.data!;
                final low = counts["low"]!;
                final medium = counts["medium"]!;
                final high = counts["high"]!;

                final hasData = (low + medium + high) > 0;

                List<ChartData> data = [];
                if (low > 0) data.add(ChartData('Thấp', low.toDouble(), Colors.green));
                if (medium > 0) data.add(ChartData('Trung bình', medium.toDouble(), Colors.orange));
                if (high > 0) data.add(ChartData('Cao', high.toDouble(), Colors.red));

                return SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: hasData
                      ? <CartesianSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      pointColorMapper: (d, _) => d.color,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.middle,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ]
                      : <CartesianSeries<ChartData, String>>[], // ⭐ Không có dữ liệu → trống
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          _buildLegend([
            LegendItem('Thấp', Colors.green),
            LegendItem('Trung bình', Colors.orange),
            LegendItem('Cao', Colors.red),
          ]),
        ],
      ),
    );
  }

  Widget _buildDateBtn(BuildContext context, String text, VoidCallback onTap) {
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
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: items.map((item) {
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
          "*Số lượng công việc theo mức độ quan trọng!",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
        ),
      ],
    );
  }
}