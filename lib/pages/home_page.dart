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

    // สำหรับการ์ด KPI
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('SpendLite')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // คงเหลือ
          _BalanceCard(amount: balance),

          const SizedBox(height: 12),

          // KPI สองกล่องในแถวเดียว
          FutureBuilder<Map<String, double>>(
            future: context.read<sl.TxnProvider>().monthlySummary(now.year, now.month),
            builder: (_, curSnap) {
              final cur = curSnap.data ?? const {'income': 0, 'expense': 0};
              return FutureBuilder<Map<String, double>>(
                future: context.read<sl.TxnProvider>().monthlySummary(prevMonth.year, prevMonth.month),
                builder: (_, prevSnap) {
                  final prev = prevSnap.data ?? const {'income': 0, 'expense': 0};
                  final incChange = _pctChange(prev['income'] ?? 0, cur['income'] ?? 0);
                  final expChange = _pctChange(prev['expense'] ?? 0, cur['expense'] ?? 0);

                  return Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: 'รายรับ',
                          icon: Icons.trending_up,
                          amount: cur['income'] ?? 0,
                          changePct: incChange,
                          positive: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          title: 'รายจ่าย',
                          icon: Icons.trending_down,
                          amount: cur['expense'] ?? 0,
                          changePct: expChange,
                          positive: false,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),
          Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 8),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('ยังไม่มีรายการ')),
            )
          else
            ...items.map((t) => _TxnTile(t: t)).toList(),
          const SizedBox(height: 72),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditTxnPage()));
          if (mounted) await context.read<sl.TxnProvider>().load();
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มรายการ'),
      ),
    );
  }

  double _pctChange(double prev, double cur) {
    if (prev <= 0) return cur > 0 ? 100.0 : 0.0;
    return ((cur - prev) / prev * 100).clamp(-999, 999);
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined),
            ),
            const SizedBox(width: 12),
            const Text('คงเหลือ', style: TextStyle(fontSize: 16)),
            const Spacer(),
            Text(
              baht(amount),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.icon,
    required this.amount,
    required this.changePct,
    required this.positive,
  });

  final String title;
  final IconData icon;
  final double amount;
  final double changePct;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final changeColor = (positive ? changePct >= 0 : changePct <= 0) ? Colors.green : Colors.red;

    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18),
              ),
              const Spacer(),
              Text(
                '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(1)}%',
                style: TextStyle(color: changeColor, fontWeight: FontWeight.w600),
              ),
            ]),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(baht(amount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            const Text('vs last month', style: TextStyle(color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.t});
  final Txn t;

  @override
  Widget build(BuildContext context) {
    final isExpense = t.type == 'expense';
    return Card(
      elevation: 0.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isExpense ? Colors.red : Colors.green).withOpacity(.15),
          child: Icon(isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: isExpense ? Colors.red : Colors.green),
        ),
        title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(t.note ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isExpense ? '-' : '+'}${baht(t.amount, withSymbol: false)}',
              style: TextStyle(fontWeight: FontWeight.w700, color: isExpense ? Colors.red : Colors.green),
            ),
            Text(
              '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => EditTxnPage(initial: t)));
          if (context.mounted) await context.read<sl.TxnProvider>().load();
        },
      ),
    );
  }
}
