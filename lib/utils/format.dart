import 'package:intl/intl.dart';

final _fmt = NumberFormat('#,##0.00');

/// แปลงจำนวนเงินเป็นสตริง
String baht(double v, {bool withSymbol = true}) {
  final s = _fmt.format(v);
  return withSymbol ? '฿$s' : s;
}

/// ใส่เครื่องหมาย + / - ตามประเภท
String signedBaht(String type, double amount, {bool withSymbol = true}) {
  final sign = type == 'expense' ? '-' : '+';
  return '$sign${baht(amount, withSymbol: withSymbol)}';
}
