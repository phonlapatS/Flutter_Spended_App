import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/txn_providers.dart' as sl;
import '../utils/format.dart';
import '../widgets/txn_tiles.dart';
// ⬇️ เพิ่ม import หน้าสำหรับเพิ่ม/แก้ไขรายการ
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<sl.TxnProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<sl.TxnProvider>();
    final txns = prov.txns;

    final now = DateTime.now();
    final int y = now.year, m = now.month;

    double monthIncome = 0, monthExpense = 0, balance = 0;
    for (final t in txns) {
      if (t.date.year == y && t.date.month == m) {
        if (t.type == 'income') {
          monthIncome += t.amount;
        } else {
          monthExpense += t.amount;
        }
      }
      balance += (t.type == 'income') ? t.amount : -t.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SpendLite'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // ===== คงเหลือ =====
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        size: 24, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('คงเหลือ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    baht(balance),
                    style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== การ์ด: รายรับ / รายจ่าย =====
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'รายรับ', amount: monthIncome, icon: Icons.trending_up),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MiniStatCard(
                  title: 'รายจ่าย', amount: monthExpense, icon: Icons.trending_down),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text('Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          ...txns.take(20).map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TxnTile(t: t),
            ),
          ),
        ],
      ),

      // ⬇️ นำทางไปหน้าเพิ่มรายการ + reload เมื่อกลับมา
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditTxnPage()),
          );
          if (mounted) context.read<sl.TxnProvider>().load();
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มรายการ'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final double amount;
  final IconData icon;

  static const double _fixedHeight = 160;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _fixedHeight,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: Colors.black54),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, constraints) => ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      baht(amount),
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w900, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
