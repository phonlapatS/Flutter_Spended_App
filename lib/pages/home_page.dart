import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spended/providers/txn_providers.dart' as sl;
import '../models/txn.dart';
import '../utils/format.dart';
import 'edit_txn_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<sl.TxnProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<sl.TxnProvider>();
    final items = prov.txns;
    final balance = prov.totalBalance;

    final now = DateTime.now();
    final currY = now.year, currM = now.month;
    final prev = DateTime(currY, currM - 1, 1);
    final prevY = prev.year, prevM = prev.month;

    return Scaffold(
      appBar: AppBar(title: const Text('Spended จ่ายแล้วจด')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, cons) {
            final w = cons.maxWidth;
            const gap = 12.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // คงเหลือ
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined),
                              const SizedBox(width: 8),
                              Text('คงเหลือ', style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              baht(balance),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: gap),

                  // การ์ดรายรับ/รายจ่าย (วางแถวเดียวกัน)
                  FutureBuilder<List<Map<String, double>>>(
                    future: () async {
                      final curr = await prov.monthlySummary(currY, currM);
                      final prev = await prov.monthlySummary(prevY, prevM);
                      return [curr, prev];
                    }(),
                    builder: (_, snap) {
                      final curr = (snap.data?[0] ?? const {'income': 0, 'expense': 0});
                      final prev = (snap.data?[1] ?? const {'income': 0, 'expense': 0});
                      final inc = curr['income'] ?? 0.0;
                      final exp = curr['expense'] ?? 0.0;
                      final incPrev = prev['income'] ?? 0.0;
                      final expPrev = prev['expense'] ?? 0.0;

                      double _pct(double now, double old) {
                        if (old <= 0) return now > 0 ? 100 : 0;
                        return ((now - old) / old) * 100;
                      }

                      final incPct = _pct(inc, incPrev);
                      final expPct = _pct(exp, expPrev);

                      if (w >= 280) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.trending_up,
                                iconBg: Colors.green.shade100,
                                title: 'รายรับ',
                                amount: inc,
                                deltaPct: incPct,
                                deltaColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: gap),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.trending_down,
                                iconBg: Colors.red.shade100,
                                title: 'รายจ่าย',
                                amount: exp,
                                deltaPct: expPct,
                                deltaColor: expPct >= 0 ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _StatCard(
                            icon: Icons.trending_up,
                            iconBg: Colors.green.shade100,
                            title: 'รายรับ',
                            amount: inc,
                            deltaPct: incPct,
                            deltaColor: Colors.green,
                          ),
                          const SizedBox(height: gap),
                          _StatCard(
                            icon: Icons.trending_down,
                            iconBg: Colors.red.shade100,
                            title: 'รายจ่าย',
                            amount: exp,
                            deltaPct: expPct,
                            deltaColor: expPct >= 0 ? Colors.red : Colors.green,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // หัวข้อ Recent (เอาปุ่ม Add Transaction ออกตามคำขอ)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Transactions',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(child: Text('ยังไม่มีรายการ', style: Theme.of(context).textTheme.bodyLarge)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _TxnTile(t: items[i]),
                    ),
                ],
              ),
            );
          },
        ),
      ),

      // ✅ ปุ่มลอย "เพิ่มรายการ" อยู่เหมือนเดิม
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditTxnPage()));
          if (!mounted) return;
          await context.read<sl.TxnProvider>().load();
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มรายการ'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final double amount;
  final double deltaPct;
  final Color deltaColor;
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.amount,
    required this.deltaPct,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${deltaPct >= 0 ? '+' : ''}${deltaPct.toStringAsFixed(1)}%';
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: Colors.black87, size: 18),
                ),
                const Spacer(),
                Text(pctText, style: TextStyle(color: deltaColor, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                baht(amount),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 2),
            Text('vs last month', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final Txn t;
  const _TxnTile({required this.t});

  @override
  Widget build(BuildContext context) {
    final isExpense = t.type == 'expense';
    final color = isExpense ? Colors.red : Colors.green;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0.5,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => EditTxnPage(initial: t)));
          if (context.mounted) await context.read<sl.TxnProvider>().load();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                child: Icon(isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.category, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if ((t.note ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(t.note!, style: const TextStyle(fontSize: 12)),
                          ),
                        if ((t.note ?? '').isNotEmpty) const SizedBox(width: 8),
                        Text(
                          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${isExpense ? '-' : '+'}${baht(t.amount)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
