import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const kGreen = Color(0xFF28C07B);

class RepeatResult {
  final String repeatText;
  final DateTime? endDate;
  final int? dailyEvery;
  final int? weeklyEvery;
  final List<bool>? weekdaySelected;
  final int? monthlyDay;
  final int? yearlyMonth;
  final int? yearlyDay;
  final int repeatType; // 0: daily, 1: weekly, 2: monthly, 3: yearly

  RepeatResult({
    required this.repeatText,
    this.endDate,
    this.dailyEvery,
    this.weeklyEvery,
    this.weekdaySelected,
    this.monthlyDay,
    this.yearlyMonth,
    this.yearlyDay,
    required this.repeatType,
  });
}

Future<RepeatResult?> showRepeatDialog(BuildContext context) {
  return showDialog<RepeatResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const RepeatDialog(),
  );
}

class RepeatDialog extends StatefulWidget {
  const RepeatDialog({super.key});

  @override
  State<RepeatDialog> createState() => _RepeatDialogState();
}

class _RepeatDialogState extends State<RepeatDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Daily
  int? _dailyEvery;

  // Weekly
  int? _weeklyEvery;
  final List<bool> _weekdaySelected = List<bool>.filled(
    7,
    false,
  ); // ban đầu chưa chọn

  // Monthly
  int? _monthlyDay;

  // Yearly
  int? _yearlyMonth;
  int? _yearlyDay;

  // End date
  bool _hasEndDate = true;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_updateTitle);

    // Khởi tạo giá trị mặc định
    final now = DateTime.now();
    _dailyEvery = 1;
    _weeklyEvery = 1;
    _monthlyDay = now.day;
    _yearlyDay = now.day;
    _yearlyMonth = now.month;

    _updateTitle();
  }

  @override
  void dispose() {
    _tabController.removeListener(_updateTitle);
    _tabController.dispose();
    super.dispose();
  }

  String _titleText = '';

  void _updateTitle() {
    String desc = '';
    switch (_tabController.index) {
      case 0:
        desc = 'Lặp lại mỗi $_dailyEvery ngày';
        break;
      case 1:
        final idx = _weekdaySelected.indexWhere((e) => e);
        const names = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];
        final dayName = idx == -1 ? 'Hằng tuần' : names[idx];
        desc = '$dayName mỗi $_weeklyEvery tuần';
        break;
      case 2:
        if (_monthlyDay == null) {
          desc = 'Hằng tháng';
        } else {
          desc =
              'Lặp lại vào ngày ${_monthlyDay.toString().padLeft(2, '0')} hàng tháng';
        }
        break;
      case 3:
        desc =
            'Lặp lại vào ${_yearlyDay.toString().padLeft(2, '0')}/${_yearlyMonth.toString().padLeft(2, '0')} hằng năm';
        break;
    }
    setState(() {
      _titleText = desc;
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ==== Cupertino bottom sheet helper ====

  Widget _buildCupertinoSheet({
    required String title,
    VoidCallback? onCancel,
    VoidCallback? onDone,
    required Widget child,
  }) {
    return Container(
      height: 280,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDone ?? () => Navigator.of(context).pop(),
                  child: const Text(
                    'Xong',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(color: Colors.grey.shade50, child: child),
          ),
        ],
      ),
    );
  }

  // ==== Pickers ====

  Future<void> _showDailyEveryPicker() async {
    int tempValue = _dailyEvery ?? 1;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _buildCupertinoSheet(
          title: 'Lặp lại mỗi ngày',
          onDone: () {
            setState(() => _dailyEvery = tempValue);
            _updateTitle();
            Navigator.of(ctx).pop();
          },
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: (_dailyEvery ?? 1) - 1,
            ),
            onSelectedItemChanged: (index) => tempValue = index + 1,
            children: List.generate(
              365,
              (i) => Center(child: Text('${i + 1}')),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showWeeklyEveryPicker() async {
    int tempValue = _weeklyEvery ?? 1;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _buildCupertinoSheet(
          title: 'Lặp lại mỗi tuần',
          onDone: () {
            setState(() => _weeklyEvery = tempValue);
            _updateTitle();
            Navigator.of(ctx).pop();
          },
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: (_weeklyEvery ?? 1) - 1,
            ),
            onSelectedItemChanged: (index) => tempValue = index + 1,
            children: List.generate(52, (i) => Center(child: Text('${i + 1}'))),
          ),
        );
      },
    );
  }

  Future<void> _showMonthlyDayPicker() async {
    int temp = _monthlyDay ?? 1;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _buildCupertinoSheet(
          title: 'Ngày trong tháng',
          onDone: () {
            setState(() => _monthlyDay = temp);
            _updateTitle();
            Navigator.of(ctx).pop();
          },
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: (_monthlyDay ?? 1) - 1,
            ),
            onSelectedItemChanged: (index) => temp = index + 1,
            children: List.generate(31, (i) => Center(child: Text('${i + 1}'))),
          ),
        );
      },
    );
  }

  Future<void> _showYearlyDayPicker() async {
    int temp = _yearlyDay ?? 1;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _buildCupertinoSheet(
          title: 'Ngày',
          onDone: () {
            setState(() => _yearlyDay = temp);
            _updateTitle();
            Navigator.of(ctx).pop();
          },
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: (_yearlyDay ?? 1) - 1,
            ),
            onSelectedItemChanged: (index) => temp = index + 1,
            children: List.generate(31, (i) => Center(child: Text('${i + 1}'))),
          ),
        );
      },
    );
  }

  Future<void> _showEndDatePicker() async {
    DateTime now = DateTime.now();
    DateTime initial = _endDate ?? now;
    DateTime minimumDate = _endDate != null ? _endDate! : now;
    DateTime temp = initial;
    bool picked = false;

    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _buildCupertinoSheet(
          title: 'Đặt ngày kết thúc lặp lại',
          onCancel: () {
            Navigator.of(ctx).pop();
          },
          onDone: () {
            picked = true;
            Navigator.of(ctx).pop();
          },
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initial,
            minimumDate: minimumDate,
            maximumYear: DateTime.now().year + 50,
            onDateTimeChanged: (d) => temp = d,
          ),
        );
      },
    );
    if (picked) {
      setState(() {
        _hasEndDate = true;
        _endDate = temp;
        _updateTitle();
      });
    }
  }

  // ==== Small widgets ====

  Widget _numberBox(int? value, VoidCallback onTap) {
    final isSelected = value != null && value > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kGreen : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? kGreen : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: isSelected
            ? Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kGreen, kGreen.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center, // Center the title
              child: Text(
                _titleText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 44,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      indicator: BoxDecoration(
                        color: kGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Hằng ngày'),
                        Tab(text: 'Hằng tuần'),
                        Tab(text: 'Hằng tháng'),
                        Tab(text: 'Hằng năm'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            SizedBox(
              // Tăng chiều cao để tránh overflow khi nội dung tab nhiều dòng
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyTab(),
                  _buildWeeklyTab(),
                  _buildMonthlyTab(),
                  _buildYearlyTab(),
                ],
              ),
            ),

            // Action Buttons
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Hủy bỏ',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        RepeatResult(
                          repeatText: _titleText,
                          endDate: _hasEndDate ? _endDate : null,
                          dailyEvery: _dailyEvery,
                          weeklyEvery: _weeklyEvery,
                          weekdaySelected: List<bool>.from(_weekdaySelected),
                          monthlyDay: _monthlyDay,
                          yearlyMonth: _yearlyMonth,
                          yearlyDay: _yearlyDay,
                          repeatType: _tabController.index,
                        ),
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _numberBox(_dailyEvery, _showDailyEveryPicker),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Lặp lại mỗi ngày', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showEndDatePicker,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _hasEndDate && _endDate != null
                        ? kGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: _hasEndDate && _endDate != null
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasEndDate && _endDate != null
                        ? 'Ngày kết thúc lặp lại: ${_formatDate(_endDate!)}'
                        : 'Ngày kết thúc lặp lại',
                    style: TextStyle(
                      fontSize: 14,
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.black87,
                      fontWeight: _hasEndDate && _endDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekday selector
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: List.generate(7, (index) {
              final selected = _weekdaySelected[index];
              return SizedBox(
                width: 36,
                height: 36,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < _weekdaySelected.length; i++) {
                        _weekdaySelected[i] = i == index;
                      }
                      _updateTitle();
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? kGreen : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: selected ? kGreen : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Repeat frequency
          Row(
            children: [
              _numberBox(_weeklyEvery, _showWeeklyEveryPicker),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Lặp lại mỗi tuần', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // End date
          GestureDetector(
            onTap: _showEndDatePicker,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _hasEndDate && _endDate != null
                        ? kGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: _hasEndDate && _endDate != null
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasEndDate && _endDate != null
                        ? 'Ngày kết thúc lặp lại: ${_formatDate(_endDate!)}'
                        : 'Ngày kết thúc lặp lại',
                    style: TextStyle(
                      fontSize: 14,
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.black87,
                      fontWeight: _hasEndDate && _endDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _showMonthlyDayPicker,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _monthlyDay != null ? kGreen : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _monthlyDay != null
                          ? kGreen
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: _monthlyDay != null
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lặp lại mỗi tháng vào ngày ${_monthlyDay.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showEndDatePicker,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _hasEndDate && _endDate != null
                        ? kGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: _hasEndDate && _endDate != null
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasEndDate && _endDate != null
                        ? 'Ngày kết thúc lặp lại: ${_formatDate(_endDate!)}'
                        : 'Ngày kết thúc lặp lại',
                    style: TextStyle(
                      fontSize: 14,
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.black87,
                      fontWeight: _hasEndDate && _endDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _showYearlyDayPicker,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _yearlyDay != null ? kGreen : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _yearlyDay != null ? kGreen : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: _yearlyDay != null
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lặp lại vào ${_yearlyDay.toString().padLeft(2, '0')}/${_yearlyMonth.toString().padLeft(2, '0')} hằng năm',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showEndDatePicker,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _hasEndDate && _endDate != null
                        ? kGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: _hasEndDate && _endDate != null
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasEndDate && _endDate != null
                        ? 'Ngày kết thúc lặp lại: ${_formatDate(_endDate!)}'
                        : 'Ngày kết thúc lặp lại',
                    style: TextStyle(
                      fontSize: 14,
                      color: _hasEndDate && _endDate != null
                          ? kGreen
                          : Colors.black87,
                      fontWeight: _hasEndDate && _endDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
