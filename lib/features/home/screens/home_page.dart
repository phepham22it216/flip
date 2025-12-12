import 'package:flutter/material.dart';
import '../widgets/status_chart.dart';
import '../widgets/important_chart.dart';
import '../widgets/rate_chart.dart';
import '../widgets/avgtime_chart.dart';
import '../widgets/ai_analysis_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          case 1: isStart ? startDate1 = picked : endDate1 = picked; break;
          case 2: isStart ? startDate2 = picked : endDate2 = picked; break;
          case 3: isStart ? startDate3 = picked : endDate3 = picked; break;
          case 4: isStart ? startDate4 = picked : endDate4 = picked; break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1050;

            // ================================
            // LEFT COLUMN: CHARTS
            // ================================
            final chartsColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChart(
                  startDate: startDate1,
                  endDate: endDate1,
                  onPickDate: pickDate,
                ),
                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, inner) {
                    final isMobile = inner.maxWidth < 700;
                    final itemW = isMobile
                        ? inner.maxWidth
                        : (inner.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemW,
                          child: ImportantChart(
                            startDate: startDate2,
                            endDate: endDate2,
                            onPickDate: pickDate,
                          ),
                        ),
                        SizedBox(
                          width: itemW,
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

                AvgTimeChart(
                  startDate: startDate4,
                  endDate: endDate4,
                  onPickDate: pickDate,
                ),
              ],
            );

            // ================================
            // RIGHT COLUMN: AI ANALYSIS
            // ================================
            final aiCard = ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 360,
              ),
              child: AIAnalysisCard(userId: userId),
            );

            // ================================
            // DESKTOP LAYOUT
            // ================================
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: chartsColumn,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 16),
                    child: aiCard,
                  ),
                ],
              );
            }

            // ================================
            // MOBILE LAYOUT
            // ================================
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  aiCard, // AI card ở trên
                  const SizedBox(height: 16),
                  chartsColumn,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
