// lib/data/app_db.dart
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/txn.dart';

class AppDB {
  static final AppDB _i = AppDB._();
  AppDB._();
  factory AppDB() => _i;

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'spendlite.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE txns(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,         -- 'income' | 'expense'
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            date TEXT NOT NULL          -- ISO8601
          );
        ''');
        await db.execute('CREATE INDEX idx_txns_date ON txns(date)');
        await db.execute('CREATE INDEX idx_txns_category ON txns(category)');
      },
    );
    return _db!;
  }

  Future<List<Txn>> getAll({String? category, String? type}) async {
    final db = await _open();
    String? where;
    final whereArgs = <Object?>[];

    if (category != null && category.isNotEmpty) {
      where = (where == null) ? 'category=?' : '$where AND category=?';
      whereArgs.add(category);
    }
    if (type != null && type.isNotEmpty) {
      where = (where == null) ? 'type=?' : '$where AND type=?';
      whereArgs.add(type);
    }

    final rows = await db.query(
      'txns',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map((m) => Txn.fromMap(m)).toList();
  }

  Future<int> insert(Txn t) async {
    final db = await _open();
    return db.insert('txns', t.toMap());
  }

  Future<int> update(Txn t) async {
    final db = await _open();
    return db.update('txns', t.toMap(), where: 'id=?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final db = await _open();
    return db.delete('txns', where: 'id=?', whereArgs: [id]);
  }

  Future<List<Txn>> getByMonth(int year, int month) async {
    final db = await _open();
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await db.query(
      'txns',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC, id ASC',
    );
    return rows.map((m) => Txn.fromMap(m)).toList();
  }

  Future<List<Txn>> getByDay(DateTime day) async {
    final db = await _open();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      'txns',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC, id ASC',
    );
    return rows.map((m) => Txn.fromMap(m)).toList();
  }
}
