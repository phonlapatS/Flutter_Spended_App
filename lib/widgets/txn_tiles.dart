import 'package:flutter/material.dart';
import '../models/txn.dart';
import '../utils/format.dart';

class TxnTile extends StatelessWidget {
  const TxnTile({super.key, required this.t});
  final Txn t;

  @override
  Widget build(BuildContext context) {
    final isExpense = t.type == 'expense';
    return ListTile(
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
            signedBaht(t.type, t.amount, withSymbol: true),
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
