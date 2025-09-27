import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 2);

String baht(double v, {bool symbol = true}) {
  final s = _money.format(v);
  return symbol ? s : s.replaceFirst('฿', '');
}

String signedBaht(String type, double amount) {
  // type: 'expense' | 'income'
  final sign = type == 'expense' ? '-' : '+';
  return '$sign${baht(amount)}';
}
