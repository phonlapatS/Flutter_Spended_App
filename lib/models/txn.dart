class Txn {
  final int? id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String? note;
  final DateTime date; // เก็บเป็น DateTime ในแอป (SQLite เก็บ ISO string)

  const Txn({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
  });

  factory Txn.fromMap(Map<String, dynamic> m) {
    return Txn(
      id: m['id'] as int?,
      type: m['type'] as String,
      amount: (m['amount'] as num).toDouble(),
      category: m['category'] as String,
      note: m['note'] as String?,
      date: DateTime.parse(m['date'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
  };

  Txn copyWith({
    int? id,
    String? type,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
  }) => Txn(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    note: note ?? this.note,
    date: date ?? this.date,
  );
}
