import 'package:flutter/material.dart';
import '../models/txn.dart';
import '../utils/format.dart';

class TxnTile extends StatelessWidget {
  final Txn t;
  final VoidCallback? onTap;
  const TxnTile({super.key, required this.t, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = t.type == 'expense';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        t.category,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(t.note?.isNotEmpty == true ? t.note! : ''),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            signedBaht(t.type, t.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          Text(
            '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
