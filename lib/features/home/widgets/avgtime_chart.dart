import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';

class AvgTimeChart extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool, int) onPickDate;

  const AvgTimeChart({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
  });

  @override
  State<AvgTimeChart> createState() => _AvgTimeChartState();
}

class _AvgTimeChartState extends State<AvgTimeChart>
    with SingleTickerProviderStateMixin {

  // Mốc thời gian tương ứng 6 mục
  final List<String> categories = [
    '<10 phút',
    '10-30 phút',
    '30 phút-1 tiếng',
    '1-3 tiếng',
    '>3 tiếng',
    'Chưa hoàn thành'
  ];

  // chứa index đang mở, null nếu đóng hết
  int? expandedIndex;

  // Sample task (bạn sẽ thay bằng task thực sau)
  final Map<String, List<String>> tasksByCategory = {
    '<10 phút': ["Uống thuốc", "Gửi email ngắn"],
    '10-30 phút': ["Dọn bàn làm việc", "Đi chợ mini"],
    '30 phút-1 tiếng': ["Làm báo cáo A"],
    '1-3 tiếng': ["Hoàn thành module Flutter"],
    '>3 tiếng': ["Phát triển tính năng lớn"],
    'Chưa hoàn thành': ["Task B", "Task C", "Task D"]
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ========================== HÀNG 1 =============================
            const Text(
              "Thời gian hoàn thành",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // ========================== HÀNG 2 =============================
            // ========================== HÀNG 2.1: BIỂU ĐỒ =============================
            SizedBox(
              width: 220,
              height: 220,
              child: SfCircularChart(
                legend: Legend(isVisible: false),
                series: <PieSeries<ChartData, String>>[
                  PieSeries<ChartData, String>(
                    dataSource: [
                      ChartData('<10p', 20, Colors.green),
                      ChartData('10-30p', 15, Colors.yellow),
                      ChartData('30p-1h', 10, Colors.orange),
                      ChartData('1-3h', 8, Colors.red),
                      ChartData('>3h', 4, Colors.purple),
                      ChartData('Chưa xong', 25, Colors.grey),
                    ],
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) => d.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

// ========================== HÀNG 2.2: LEGEND (WEB = 1 hàng, MOBILE = 2/1 hàng) =============================
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWeb = constraints.maxWidth > 500;

                return isWeb
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildLegendItems(),
                )
                    : Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: _buildLegendItems(),
                );
              },
            ),

            const SizedBox(height: 16),

            // ========================== HÀNG 3: BẢNG =============================
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: (expandedIndex == null)
                  ? const SizedBox.shrink()
                  : _buildTaskTable(categories[expandedIndex!]),
            ),

            const SizedBox(height: 16),

            // ========================== HÀNG 4 =============================
            const Text(
              "*Trung bình thời gian bạn hoàn thành công việc ngày hôm nay!",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD LEGEND LIST WITH TOGGLE
  Widget _buildLegendList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(categories.length, (index) {
        final label = categories[index];
        final colors = [
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
          Colors.purple,
          Colors.grey,
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(width: 16, height: 16, color: colors[index]),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
              IconButton(
                icon: Icon(
                  expandedIndex == index
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    expandedIndex = (expandedIndex == index) ? null : index;
                  });
                },
              )
            ],
          ),
        );
      }),
    );
  }

  // BẢNG HIỂN THỊ TASK
  Widget _buildTaskTable(String category) {
    final tasks = tasksByCategory[category] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Danh Sách Các Công Việc Liên Quan",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("- $task"),
        )),
      ],
    );
  }

  List<Widget> _buildLegendItems() {
    final colors = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.grey,
    ];

    return List.generate(categories.length, (index) {
      final label = categories[index];

      return SizedBox(
        width: 150, // để mobile xuống dòng đúng 2 item/hàng
        child: Row(
          children: [
            Container(width: 16, height: 16, color: colors[index]),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            IconButton(
              icon: Icon(
                expandedIndex == index
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                setState(() {
                  expandedIndex = expandedIndex == index ? null : index;
                });
              },
            )
          ],
        ),
      );
    });
  }
}
