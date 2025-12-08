import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';

class ImportantChart extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool, int) onPickDate;

  const ImportantChart({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return _buildColumnChart(
      context: context,
      title: "- Mức Độ Quan Trọng -",
      startDate: startDate,
      endDate: endDate,
      onPickDate: onPickDate,
      chartIndex: 2,
      data: [
        ChartData('Thấp', 5, Colors.green),
        ChartData('Trung bình', 8, Colors.orange),
        ChartData('Cao', 3, Colors.red),
      ],
      legendItems: [
        LegendItem('Thấp', Colors.green),
        LegendItem('Trung bình', Colors.orange),
        LegendItem('Cao', Colors.red),
      ],
    );
  }

  Widget _buildColumnChart({
    required BuildContext context,
    required String title,
    required DateTime? startDate,
    required DateTime? endDate,
    required void Function(BuildContext, bool, int) onPickDate,
    required int chartIndex,
    required List<ChartData> data,
    required List<LegendItem> legendItems,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateBtn(context, "Bắt đầu", () => onPickDate(context, true, chartIndex)),
              const SizedBox(width: 10),
              _buildDateBtn(context, "Kết thúc", () => onPickDate(context, false, chartIndex)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: <CartesianSeries<ChartData, String>>[
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
              ],
            ),
          ),
          _buildLegend(legendItems),
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
      crossAxisAlignment: CrossAxisAlignment.center, // căn trái
      children: [
        // Hàng ghi chú màu
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

        // 👉 Dòng mô tả thêm
        const Text(
          "*Số lượng công việc theo mức độ quan trọng!",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
