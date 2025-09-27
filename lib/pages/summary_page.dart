import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../providers/txn_providers.dart' as sl;
import '../utils/format.dart';
import '../theme/category_colors.dart';

enum RangeView { day, month }

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});
  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  RangeView _range = RangeView.month;
  String _viewType = 'expense'; // 'expense' | 'income'
  late DateTime _month;
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _day = DateTime(now.year, now.month, now.day);
  }

  void _prev() {
    setState(() {
      if (_range == RangeView.month) {
        _month = DateTime(_month.year, _month.month - 1, 1);
      } else {
        _day = _day.subtract(const Duration(days: 1));
      }
    });
  }

  void _next() {
    setState(() {
      if (_range == RangeView.month) {
        _month = DateTime(_month.year, _month.month + 1, 1);
      } else {
        _day = _day.add(const Duration(days: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<sl.TxnProvider>();
    final titleText = _range == RangeView.month
        ? '${_month.year}-${_month.month.toString().padLeft(2, '0')}'
        : '${_day.year}-${_day.month.toString().padLeft(2, '0')}-${_day.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปรายเดือน (Pie Chart)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 8),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                ButtonSegment(value: 'income', label: Text('รายรับ')),
              ],
              style: const ButtonStyle(
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
              ),
              selected: {_viewType},
              onSelectionChanged: (s) => setState(() => _viewType = s.first),
            ),
            const SizedBox(height: 8),

            SegmentedButton<RangeView>(
              segments: const [
                ButtonSegment(value: RangeView.day, label: Text('รายวัน')),
                ButtonSegment(value: RangeView.month, label: Text('รายเดือน')),
              ],
              style: const ButtonStyle(
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
              ),
              selected: {_range},
              onSelectionChanged: (s) => setState(() => _range = s.first),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<dynamic>>(
              future: () async {
                final Map<String, double> byCat = _range == RangeView.month
                    ? await prov.monthlyByCategory(_month.year, _month.month, type: _viewType)
                    : await prov.dailyByCategory(_day, type: _viewType);
                Map<String, double>? monthSum;
                if (_range == RangeView.month) {
                  monthSum = await prov.monthlySummary(_month.year, _month.month);
                }
                return [byCat, monthSum];
              }(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = (snap.data?[0] as Map<String, double>?) ?? {};
                final monthSum = snap.data?[1] as Map<String, double>?;
                final total = data.values.fold<double>(0, (p, v) => p + v);

                if (data.isEmpty || total == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: Text(
                        _viewType == 'expense'
                            ? (_range == RangeView.month ? 'ยังไม่มีรายจ่ายในเดือนนี้' : 'ยังไม่มีรายจ่ายในวันนี้')
                            : (_range == RangeView.month ? 'ยังไม่มีรายรับในเดือนนี้' : 'ยังไม่มีรายรับในวันนี้'),
                      ),
                    ),
                  );
                }

                final sections = <PieChartSectionData>[];
                final entries = data.entries.toList();
                for (var i = 0; i < entries.length; i++) {
                  final cat = entries[i].key;
                  final amount = entries[i].value;
                  final pct = (amount / total) * 100;
                  sections.add(
                    PieChartSectionData(
                      value: amount,
                      color: catColor(cat),
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      radius: 80,
                    ),
                  );
                }

                final monthIncome = (monthSum ?? const {})['income'] ?? 0.0;

                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.25,
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, idx) {
                        final cat = entries[idx].key;
                        final amount = entries[idx].value;

                        late final String rightText;
                        if (_range == RangeView.month && _viewType == 'expense') {
                          rightText = (monthIncome > 0)
                              ? '${(amount / monthIncome * 100).toStringAsFixed(0)}%'
                              : '—%';
                        } else {
                          rightText = '${(amount / total * 100).toStringAsFixed(0)}%';
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: catColor(cat),
                            radius: 12,
                            child: Icon(
                              catIcon(cat),
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(cat),
                          subtitle: Text(baht(amount)),
                          trailing: Text(
                            rightText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
