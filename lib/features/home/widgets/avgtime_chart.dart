import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_model.dart';
import '../services/avgtimechart_service.dart';

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
  final AvgTimeChartService _service = AvgTimeChartService();

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

  // dữ liệu động (thay cho sample)
  Map<String, List<String>> tasksByCategory = {};
  List<ChartData> chartData = [];
  Map<String, double> taskDurations = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // load dữ liệu khi widget khởi tạo
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Nếu widget.startDate/endDate là null thì service sẽ set mặc định ngày nguyên hôm nay
    final res = await _service.calculateAvgTimeData(
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    // Lưu data
    setState(() {
      chartData = res.chartData;
      tasksByCategory = res.tasksByCategory;
      taskDurations = res.taskDurations;
      _loading = false;
    });
  }

  @override
  void didUpdateWidget(covariant AvgTimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu user thay đổi ngày ở parent thì reload data
    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate) {
      _loadData();
    }
  }

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

            const Text(
              "Thời gian hoàn thành",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // BIỂU ĐỒ + LEGEND
            _loading
                ? const SizedBox(
              width: 220,
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
                : SizedBox(
              width: 220,
              height: 220,
              child: chartData.isEmpty
                  ? SfCircularChart(
                // Không có dữ liệu -> vẽ 1 vòng tròn nhạt hoặc để trống
                series: <CircularSeries<dynamic, String>>[],
              )
                  : SfCircularChart(
                legend: Legend(isVisible: false),
                series: <PieSeries<ChartData, String>>[
                  PieSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) => d.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    dataLabelMapper: (item, _) =>
                    "${item.value.toStringAsFixed(1)}%",
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LEGEND responsive (web / mobile)
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWeb = constraints.maxWidth > 500;
                final items = [
                  LegendItem('<10 phút', Colors.green),
                  LegendItem('10-30 phút', Colors.yellow),
                  LegendItem('30 phút-1 tiếng', Colors.orange),
                  LegendItem('1-3 tiếng', Colors.red),
                  LegendItem('>3 tiếng', Colors.purple),
                  LegendItem('Chưa hoàn thành', Colors.grey),
                ];

                return isWeb
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildLegendItems(items),
                )
                    : Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: _buildLegendItems(items),
                );
              },
            ),

            const SizedBox(height: 16),

            // Bảng (animated)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: (expandedIndex == null)
                  ? const SizedBox.shrink()
                  : _buildTaskTable(categories[expandedIndex!]),
            ),

            const SizedBox(height: 16),

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

  List<Widget> _buildLegendItems(List<LegendItem> legendItems) {
    return List.generate(legendItems.length, (index) {
      final item = legendItems[index];
      final label = item.label;

      return SizedBox(
        width: 150,
        child: Row(
          children: [
            Container(width: 16, height: 16, color: item.color),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            IconButton(
              icon: Icon(
                expandedIndex == index ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
          child: Text(
            "Danh Sách Các Công Việc: $category (${tasks.length})",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Không có công việc trong mốc này."),
          )
        else
          ...tasks.map((taskName) {
            final duration = taskDurations[taskName];
            final durText = duration != null ? " - ${duration.toStringAsFixed(0)} phút" : "";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text("- $taskName$durText"),
            );
          }),
      ],
    );
  }
}