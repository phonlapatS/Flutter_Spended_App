import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/txn.dart';
import 'package:spended/providers/txn_providers.dart' as prov;

// สี + ไอคอนของหมวด (ทั้งรายจ่าย/รายรับ)
import '../theme/category_colors.dart';

class EditTxnPage extends StatefulWidget {
  final Txn? initial;
  const EditTxnPage({super.key, this.initial});

  @override
  State<EditTxnPage> createState() => _EditTxnPageState();
}

class _EditTxnPageState extends State<EditTxnPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense'; // 'expense' | 'income'
  String _category = '';
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  List<String> get _currentCats =>
      _type == 'expense' ? kExpenseCategories : kIncomeCategories;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      _type = t.type;
      _category = t.category;
      _amountCtrl.text = t.amount.toStringAsFixed(2);
      _noteCtrl.text = t.note ?? '';
      _date = t.date;
    } else {
      // ค่าเริ่มต้นของหมวดตามประเภท
      _category = (_type == 'expense' ? kExpenseCategories : kIncomeCategories).first;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (res != null) setState(() => _date = res);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text);
    final base = Txn(
      id: widget.initial?.id,
      type: _type,
      amount: amount,
      category: _category,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      date: _date,
    );

    final p = context.read<prov.TxnProvider>();
    if (widget.initial == null) {
      await p.add(base);
    } else {
      await p.updateTxn(base);
    }
    if (mounted) Navigator.pop(context);
  }

  DropdownMenuItem<String> _buildCatItem(String cat) {
    return DropdownMenuItem<String>(
      value: cat,
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: catColor(cat),
            child: Icon(catIcon(cat), size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(cat),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขรายการ' : 'เพิ่มรายการ'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('ลบรายการนี้?'),
                    content: const Text('ยืนยันการลบ'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('ยกเลิก'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('ลบ'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await context
                      .read<prov.TxnProvider>()
                      .remove(widget.initial!.id!);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // เลือกประเภท รายจ่าย / รายรับ
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('รายจ่าย'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('รายรับ'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  final nextType = s.first;
                  setState(() {
                    _type = nextType;
                    // เปลี่ยนประเภทแล้วให้รีเซ็ตหมวดให้ตรงกับชุดใหม่
                    final cats =
                        _type == 'expense' ? kExpenseCategories : kIncomeCategories;
                    _category = cats.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity(horizontal: -1, vertical: -1),
                ),
              ),
              const SizedBox(height: 12),

              // จำนวนเงิน
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'จำนวนเงิน (฿)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final x = double.tryParse(v ?? '');
                  if (x == null || x <= 0) {
                    return 'กรอกจำนวนเงินให้ถูกต้อง (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // หมวดหมู่ (Dropdown พร้อมไอคอน+สี)
              DropdownButtonFormField<String>(
                value: _category.isNotEmpty ? _category : _currentCats.first,
                isExpanded: true,
                items: _currentCats.map(_buildCatItem).toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // วันที่
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: const Text('วันที่'),
                subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),

              // โน้ต
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'โน้ต (ถ้ามี)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                minLines: 1,
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
