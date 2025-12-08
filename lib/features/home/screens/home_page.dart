import 'package:flutter/material.dart';
import '../widgets/status_chart.dart';
import '../widgets/important_chart.dart';
import '../widgets/rate_chart.dart';
import '../widgets/avgtime_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? startDate1, endDate1;
  DateTime? startDate2, endDate2;
  DateTime? startDate3, endDate3;
  DateTime? startDate4, endDate4;

  Future<void> pickDate(BuildContext context, bool isStart, int chart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        switch (chart) {
          case 1:
            isStart ? startDate1 = picked : endDate1 = picked;
            break;
          case 2:
            isStart ? startDate2 = picked : endDate2 = picked;
            break;
          case 3:
            isStart ? startDate3 = picked : endDate3 = picked;
            break;
          case 4:
            isStart ? startDate4 = picked : endDate4 = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusChart(startDate: startDate1, endDate: endDate1, onPickDate: pickDate),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 700;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 16) / 2,
                        child: ImportantChart(
                          startDate: startDate2,
                          endDate: endDate2,
                          onPickDate: pickDate,
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 16) / 2,
                        child: RateChart(
                          startDate: startDate3,
                          endDate: endDate3,
                          onPickDate: pickDate,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              AvgTimeChart(startDate: startDate4, endDate: endDate4, onPickDate: pickDate),
            ],
          ),
        ),
      ),
    );
  }
}
