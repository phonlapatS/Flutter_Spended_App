import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spended/providers/txn_providers.dart' as sl;

import '../utils/format.dart';
import 'edit_txn_page.dart';

// ใช้ radius เดียวกันทุกการ์ด
const double _kCardRadius = 16;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendLite'),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          // การ์ดคงเหลือ
          Card(
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kCardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('คงเหลือ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Text(
                    baht(balance),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2 ใบ : รายรับ / รายจ่าย (อยู่แถวเดียวกัน, radius เท่ากัน)
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'รายรับ',
                  amount: prov.monthIncome, // ค่าที่ provider คำนวณ
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: 'รายจ่าย',
                  amount: prov.monthExpense, // ค่าที่ provider คำนวณ
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // หัวข้อ Recent Transactions (ไม่มีปุ่ม Add ตรงนี้แล้ว)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 8),

          // รายการธุรกรรม
          if (items.isEmpty)
            Card(
              color: Colors.white,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kCardRadius),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('ยังไม่มีรายการ')),
              ),
            )
          else
            ...items.map((t) {
              final isExpense = t.type == 'expense';
              return Card(
                color: Colors.white,
                elevation: 0.5,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        isExpense ? Colors.red.shade50 : Colors.green.shade50,
                    child: Icon(
                      isExpense
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    t.category,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(t.note ?? ''),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense ? '-' : '+'}${baht(t.amount, withSymbol: false)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
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
                      MaterialPageRoute(
                        builder: (_) => EditTxnPage(initial: t),
                      ),
                    );
                    if (!mounted) return;
                    await context.read<sl.TxnProvider>().load();
                  },
                ),
              );
            }),
        ],
      ),

      // เอาปุ่มเพิ่มรายการ (FAB) กลับมา
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditTxnPage()),
          );
          if (!mounted) return;
          await context.read<sl.TxnProvider>().load();
        },
        label: const Text('เพิ่มรายการ'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  const _MiniStatCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              baht(amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
