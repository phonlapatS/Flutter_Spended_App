import 'dart:math';

/// แปลงเป็นสกุลบาทแบบง่าย ๆ (ไม่พึ่ง intl)
String baht(num value, {bool withSymbol = true}) {
  final isNeg = value < 0;
  final v = value.abs();
  final s = v.toStringAsFixed(2);
  return withSymbol ? '${isNeg ? "-" : ""}฿$s' : '${isNeg ? "-" : ""}$s';
}

/// แสดงเครื่องหมาย +/- จากชนิดรายการ
/// type: 'expense' | 'income'
String signedBaht(String type, num amount, {bool withSymbol = true}) {
  final s = baht(amount, withSymbol: withSymbol);
  if (type == 'expense') {
    // ถ้าเป็นรายจ่ายให้มี '-' ข้างหน้าเสมอ
    return withSymbol ? '-$s'.replaceFirst('฿', '฿') : '-$s';
  }
  // รายรับเป็น '+'
  return withSymbol ? '+$s' : '+$s';
}
