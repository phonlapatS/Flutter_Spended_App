import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spended/providers/txn_providers.dart' as prov;
import '../theme/category_colors.dart';
import '../utils/format.dart';

enum RangeView { day, month }

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});
  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  RangeView _range = RangeView.month;
  String _viewType = 'expense';
  late DateTime _month;
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _day = DateTime(now.year, now.month, now.day);
  }

  void _prev() => setState(() {
        if (_range == RangeView.month) {
          _month = DateTime(_month.year, _month.month - 1, 1);
        } else {
          _day = _day.subtract(const Duration(days: 1));
        }
      });

  void _next() => setState(() {
        if (_range == RangeView.month) {
          _month = DateTime(_month.year, _month.month + 1, 1);
        } else {
          _day = _day.add(const Duration(days: 1));
        }
      });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<prov.TxnProvider>();
    final title = _range == RangeView.month
        ? '${_month.year}-${_month.month.toString().padLeft(2, '0')}'
        : '${_day.year}-${_day.month.toString().padLeft(2, '0')}-${_day.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปค่าใช้จ่าย')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
                      Expanded(
                        child: Text(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                      ),
                      IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ฟิลเตอร์: ทำให้เตี้ยและไม่กินพื้นที่
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                            ButtonSegment(value: 'income', label: Text('รายรับ')),
                          ],
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
                          ),
                          selected: {_viewType},
                          onSelectionChanged: (s) => setState(() => _viewType = s.first),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SegmentedButton<RangeView>(
                          segments: const [
                            ButtonSegment(value: RangeView.day, label: Text('รายวัน')),
                            ButtonSegment(value: RangeView.month, label: Text('รายเดือน')),
                          ],
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
                          ),
                          selected: {_range},
                          onSelectionChanged: (s) => setState(() => _range = s.first),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // เนื้อหา
          SliverFillRemaining(
            hasScrollBody: true,
            child: FutureBuilder<List<dynamic>>(
              future: () async {
                final Map<String, double> byCat = _range == RangeView.month
                    ? await p.monthlyByCategory(_month.year, _month.month, type: _viewType)
                    : await p.dailyByCategory(_day, type: _viewType);
                Map<String, double>? monthSum;
                if (_range == RangeView.month) {
                  monthSum = await p.monthlySummary(_month.year, _month.month);
                }
                return [byCat, monthSum];
              }(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = (snap.data?[0] as Map<String, double>?) ?? {};
                final monthSum = snap.data?[1] as Map<String, double>?; // null เมื่อรายวัน
                final total = data.values.fold<double>(0, (p, v) => p + v);

                if (data.isEmpty || total == 0) {
                  return Center(
                    child: Text(_viewType == 'expense'
                        ? (_range == RangeView.month ? 'ยังไม่มีรายจ่ายในเดือนนี้' : 'ยังไม่มีรายจ่ายในวันนี้')
                        : (_range == RangeView.month ? 'ยังไม่มีรายรับในเดือนนี้' : 'ยังไม่มีรายรับในวันนี้')),
                  );
                }

                // Section pie
                final sections = <PieChartSectionData>[];
                data.forEach((cat, amount) {
                  final c = pickCategoryColor(_viewType, cat);
                  final pct = (amount / total) * 100;
                  sections.add(
                    PieChartSectionData(
                      value: amount,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      radius: 78,
                      color: c,
                    ),
                  );
                });

                final monthIncome = (monthSum ?? const {})['income'] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.15,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'รวม ${_viewType == "expense" ? "รายจ่าย" : "รายรับ"}: ${baht(total)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final e = data.entries.elementAt(i);
                            final color = pickCategoryColor(_viewType, e.key);
                            String right;
                            if (_range == RangeView.month && _viewType == 'expense' && monthIncome > 0) {
                              right = '${(e.value / monthIncome * 100).toStringAsFixed(0)}%';
                            } else {
                              right = '${(e.value / total * 100).toStringAsFixed(0)}%';
                            }
                            return ListTile(
                              leading: CircleAvatar(backgroundColor: color, radius: 6),
                              title: Text(e.key),
                              subtitle: Text(baht(e.value)),
                              trailing: Text(right, style: const TextStyle(fontWeight: FontWeight.w600)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
