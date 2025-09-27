// lib/providers/txn_providers.dart
import 'package:flutter/foundation.dart';
import '../data/app_db.dart';
import '../models/txn.dart';

class TxnProvider extends ChangeNotifier {
  final _db = AppDB();

  List<Txn> _txns = [];
  String _filterCategory = '';
  String _filterType = '';

  List<Txn> get txns => _txns;
  String get filterCategory => _filterCategory;
  String get filterType => _filterType;

  /// โหลดรายการ (สามารถกรอง category / type ได้)
  Future<void> load({String? category, String? type}) async {
    _filterCategory = category ?? _filterCategory;
    _filterType = type ?? _filterType;

    _txns = await _db.getAll(
      category: _filterCategory.isEmpty ? null : _filterCategory,
      type: _filterType.isEmpty ? null : _filterType,
    );
    notifyListeners();
  }

  /// ยอดคงเหลือจากรายการที่โหลดอยู่ตอนนี้
  double get totalBalance {
    double bal = 0;
    for (final t in _txns) {
      bal += (t.type == 'income') ? t.amount : -t.amount;
    }
    return bal;
  }

  /// >>> เพิ่มสอง getter นี้ เพื่อใช้กับการ์ด “รายรับ/รายจ่าย” <<<
  double get monthIncome =>
      _txns.where((t) => t.type == 'income').fold(0.0, (p, t) => p + t.amount);

  double get monthExpense =>
      _txns.where((t) => t.type == 'expense').fold(0.0, (p, t) => p + t.amount);

  Future<void> add(Txn t) async {
    await _db.insert(t);
    await load();
  }

  Future<void> updateTxn(Txn t) async {
    await _db.update(t);
    await load();
  }

  Future<void> remove(int id) async {
    await _db.delete(id);
    await load();
  }

  /// สรุปทั้งเดือน (รวมรายรับ/รายจ่าย/คงเหลือ)
  Future<Map<String, double>> monthlySummary(int year, int month) async {
    final list = await _db.getByMonth(year, month);
    double inc = 0, exp = 0;
    for (final t in list) {
      if (t.type == 'income') {
        inc += t.amount;
      } else {
        exp += t.amount;
      }
    }
    return {'income': inc, 'expense': exp, 'balance': inc - exp};
  }

  /// สรุปรายวัน
  Future<Map<String, double>> dailySummary(DateTime day) async {
    final list = await _db.getByDay(day);
    double inc = 0, exp = 0;
    for (final t in list) {
      if (t.type == 'income') {
        inc += t.amount;
      } else {
        exp += t.amount;
      }
    }
    return {'income': inc, 'expense': exp, 'balance': inc - exp};
  }

  /// สรุปแยกตามหมวดหมู่ (ทั้งเดือน) พร้อม option กรองชนิด
  Future<Map<String, double>> monthlyByCategory(
    int year,
    int month, {
    String? type, // 'expense' | 'income' | null = รวมทั้งสองฝั่ง
  }) async {
    final list = await _db.getByMonth(year, month);
    final Map<String, double> sum = {};
    for (final t in list) {
      if (type != null && t.type != type) continue;
      sum[t.category] = (sum[t.category] ?? 0) + t.amount;
    }
    final entries = sum.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  /// สรุปแยกตามหมวดหมู่ (รายวัน) พร้อม option กรองชนิด
  Future<Map<String, double>> dailyByCategory(
    DateTime day, {
    String? type, // 'expense' | 'income' | null
  }) async {
    final list = await _db.getByDay(day);
    final Map<String, double> sum = {};
    for (final t in list) {
      if (type != null && t.type != type) continue;
      sum[t.category] = (sum[t.category] ?? 0) + t.amount;
    }
    final entries = sum.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }
}
