// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spended/providers/txn_providers.dart' as sl;
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
    // โหลดข้อมูลครั้งแรก
    Future.microtask(() => context.read<sl.TxnProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<sl.TxnProvider>();
    final items = prov.txns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendLite'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // การ์ดคงเหลือ
          _BalanceCard(balance: prov.totalBalance),

          const SizedBox(height: 12),

          // การ์ด รายรับ / รายจ่าย (อยู่แถวเดียวกัน)
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'รายรับ',
                  amount: prov.monthIncome,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: 'รายจ่าย',
                  amount: prov.monthExpense,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('ยังไม่มีรายการ')),
              ),
            )
          else
            ...items.map((t) {
              final isExpense = t.type == 'expense';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTxnPage(initial: t),
                      ),
                    );
                    if (mounted) await context.read<sl.TxnProvider>().load();
                  },
                  leading: CircleAvatar(
                    backgroundColor:
                        isExpense ? Colors.red.shade100 : Colors.green.shade100,
                    child: Icon(
                      isExpense
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    t.category,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(t.note ?? ''),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // >>> แก้ตรงนี้: เอา withSymbol ออก <<<
                      Text(
                        '${isExpense ? '-' : '+'}${baht(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 72),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditTxnPage()),
          );
          if (mounted) await context.read<sl.TxnProvider>().load();
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มรายการ'),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    final color = balance >= 0 ? Colors.green : Colors.red;
    return Card(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('คงเหลือ', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    baht(balance),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              baht(amount),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
