// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spended/providers/txn_providers.dart' as sl;
import 'edit_txn_page.dart';
import '../utils/format.dart';

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
    final balance = prov.totalBalance;
    final income = prov.monthIncome;   // ⬅ ใช้ getter ใหม่
    final expense = prov.monthExpense; // ⬅ ใช้ getter ใหม่

    return Scaffold(
      appBar: AppBar(title: const Text('SpendLite')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // การ์ดคงเหลือ
          Card(
            elevation: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('คงเหลือ', style: TextStyle(fontSize: 16)),
                  ),
                  Text(
                    baht(balance),
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // แถวการ์ด “รายรับ / รายจ่าย”
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'รายรับ',
                  amount: income,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: 'รายจ่าย',
                  amount: expense,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // หัวข้อ Recent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),

          // รายการธุรกรรม
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('ยังไม่มีรายการ')),
            )
          else
            ...items.map((t) {
              final isExpense = t.type == 'expense';
              return Card(
                elevation: 0.3,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isExpense
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    child: Icon(
                      isExpense ? Icons.remove : Icons.add,
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
                      // ⬇️ เอา withSymbol ออก
                      Text(
                        '${isExpense ? '-' : '+'}${baht(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditTxnPage(initial: t)),
                    );
                    if (mounted) await context.read<sl.TxnProvider>().load();
                  },
                ),
              );
            }),
        ],
      ),

      // FAB (คงไว้ตามที่ขอ)
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
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up),
                ),
                const Spacer(),
                // ตำแหน่งใส่ % growth ภายหลัง (ถ้าต้องการ)
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              baht(amount),
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
