String baht(double v) => '฿' + v.toStringAsFixed(2);
String signedBaht(String type, double v) =>
    (type == 'expense' ? '-' : '+') + baht(v);
