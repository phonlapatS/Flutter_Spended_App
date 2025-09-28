import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/txn.dart';
import '../providers/txn_providers.dart' as prov;
import '../theme/category_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final cats = _type == 'expense'
        ? kExpenseColors.keys.toList()
        : kIncomeColors.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'เพิ่มรายการ' : 'แก้ไขรายการ')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                ButtonSegment(value: 'income', label: Text('รายรับ')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                // ถ้าหมวดปัจจุบันไม่อยู่ในชุด ให้รีเซ็ตค่าเริ่มต้น
                if (_type == 'expense' && !kExpenseColors.containsKey(_category)) {
                  _category = 'อาหาร';
                } else if (_type == 'income' && !kIncomeColors.containsKey(_category)) {
                  _category = 'เงินเดือน';
                }
              }),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _category,
              items: [
                for (final c in cats)
                  DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Container(
                          width: 10, height: 10,
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

            TextFormField(
              initialValue: _amount == 0 ? '' : _amount.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
              validator: (v) => (v == null || v.isEmpty) ? 'กรอกจำนวนเงิน' : null,
              onSaved: (v) => _amount = double.tryParse(v ?? '0') ?? 0,
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _note,
              decoration: const InputDecoration(labelText: 'หมายเหตุ'),
              onSaved: (v) => _note = v,
            ),
            const SizedBox(height: 12),

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
                    builder: (ctx, child) {
                      // ปรับป๊อปอัปปฏิทินพื้นขาว
                      return Theme(
                        data: Theme.of(ctx).copyWith(
                          dialogBackgroundColor: Colors.white,
                          colorScheme: Theme.of(ctx).colorScheme.copyWith(surface: Colors.white),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
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

                final p = context.read<prov.TxnProvider>();
                if (t.id == null) {
                  await p.add(t);
                } else {
                  await p.updateTxn(t);
                }
                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
