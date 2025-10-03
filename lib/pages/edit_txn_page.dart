// lib/pages/edit_txn_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spended/providers/txn_providers.dart' as sl;

import '../models/txn.dart';
import '../theme/category_colors.dart'; // pickCategoryColor / pickCategoryIcon

class EditTxnPage extends StatefulWidget {
  const EditTxnPage({super.key, this.initial});
  final Txn? initial;

  @override
  State<EditTxnPage> createState() => _EditTxnPageState();
}

class _EditTxnPageState extends State<EditTxnPage> {
  final _form = GlobalKey<FormState>();

  String _type = 'expense';
  String _category = 'อาหาร';
  DateTime _date = DateTime.now();
  String? _note;
  double _amount = 0;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      _type = t.type;
      _category = t.category;
      _date = t.date;
      _note = t.note;
      _amount = t.amount;
    }
  }

  Future<void> _confirmDelete() async {
    final id = widget.initial?.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: const Text('คุณต้องการลบรายการนี้ถาวรหรือไม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<sl.TxnProvider>().remove(id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == 'expense';
    final cats = isExpense ? kExpenseColors.keys.toList() : kIncomeColors.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'เพิ่มรายการ' : 'แก้ไขรายการ'),
        centerTitle: true,
        // ✅ แสดงปุ่มลบเมื่อเป็นโหมดแก้ไข
        actions: [
          if (widget.initial?.id != null)
            IconButton(
              tooltip: 'ลบรายการ',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── ประเภท ───────────────────────────────────────────────
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                ButtonSegment(value: 'income', label: Text('รายรับ')),
              ],
              showSelectedIcon: false,
              selected: {_type},
              onSelectionChanged: (s) {
                setState(() {
                  _type = s.first;
                  // ตั้งค่าหมวดเริ่มต้นให้ตรงชนิด
                  if (_type == 'expense' && !kExpenseColors.containsKey(_category)) {
                    _category = 'อาหาร';
                  } else if (_type == 'income' && !kIncomeColors.containsKey(_category)) {
                    _category = 'เงินเดือน';
                  }
                });
              },
            ),
            const SizedBox(height: 12),

            // ── หมวดหมู่ ─────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _category,
              items: [
                for (final c in cats)
                  DropdownMenuItem<String>(
                    value: c,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: pickCategoryColor(_type, c),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(pickCategoryIcon(_type, c), size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(c),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'หมวดหมู่'),
            ),
            const SizedBox(height: 12),

            // ── จำนวนเงิน ────────────────────────────────────────────
            TextFormField(
              initialValue: _amount == 0 ? '' : _amount.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรอกจำนวนเงิน';
                final d = double.tryParse(v.replaceAll(',', ''));
                if (d == null) return 'รูปแบบไม่ถูกต้อง';
                if (d <= 0) return 'ต้องมากกว่า 0';
                return null;
              },
              onSaved: (v) => _amount = double.tryParse(v?.replaceAll(',', '') ?? '0') ?? 0,
            ),
            const SizedBox(height: 12),

            // ── หมายเหตุ ─────────────────────────────────────────────
            TextFormField(
              initialValue: _note,
              decoration: const InputDecoration(labelText: 'หมายเหตุ'),
              onSaved: (v) => _note = v?.trim().isEmpty == true ? null : v,
            ),
            const SizedBox(height: 12),

            // ── วันที่ ───────────────────────────────────────────────
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: const Text('วันที่'),
                subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── ปุ่มบันทึก ───────────────────────────────────────────
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('บันทึก'),
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                _form.currentState!.save();

                final t = Txn(
                  id: widget.initial?.id,
                  type: _type,
                  amount: _amount,
                  category: _category,
                  note: _note,
                  date: _date,
                );

                final p = context.read<sl.TxnProvider>();
                if (t.id == null) {
                  await p.add(t);
                } else {
                  await p.updateTxn(t);
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
