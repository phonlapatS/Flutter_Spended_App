// lib/widgets/txn_tiles.dart
import 'package:flutter/material.dart';
import '../models/txn.dart';
import '../utils/format.dart';
import '../pages/edit_txn_page.dart'; 

class TxnTile extends StatelessWidget {
  const TxnTile({super.key, required this.t});
  final Txn t;

  @override
  Widget build(BuildContext context) {
    final isExpense = t.type == 'expense';
    return ListTile(
      onTap: () async {
        // เปิดหน้าแก้ไข โดยส่งโมเดลเดิมไป
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditTxnPage(initial: t)),
        );
      },
      leading: CircleAvatar(
        backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
        child: Icon(
          isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
          color: isExpense ? Colors.red : Colors.green,
        ),
      ),
      title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(t.note ?? ''),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            signedBaht(t.type, t.amount), // ⬅️ ไม่มีพารามิเตอร์ withSymbol แล้ว
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          Text('${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}'),
        ],
      ),
    );
  }
}
