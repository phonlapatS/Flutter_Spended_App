import 'package:flutter/material.dart';

/// ===== รายจ่าย (Expense) =====
const Map<String, Color> _expenseColors = {
  'อาหาร': Color(0xFFFF9800),        // ส้ม
  'เดินทาง': Color(0xFF42A5F5),      // ฟ้า sky
  'ช้อปปิ้ง': Color(0xFFE91E63),      // ชมพู/แดง
  'บิล': Color(0xFF7E57C2),           // ม่วง
  'นันทนาการ': Color(0xFFFFEB3B),   // เหลือง
  'ยา': Color(0xFF4CAF50),           // เขียว
  'ความงาม': Color(0xFFFF80AB),     // ชมพู
  'สังคม': Color(0xFF1565C0),        // น้ำเงิน
  'อื่นๆ': Color(0xFF90A4AE),        // เทา
};

const List<String> kExpenseCategories = [
  'อาหาร',
  'เดินทาง',
  'ช้อปปิ้ง',
  'บิล',
  'นันทนาการ',
  'ยา',
  'ความงาม',
  'สังคม',
  'อื่นๆ',
];

/// ===== รายรับ (Income) =====
const Map<String, Color> _incomeColors = {
  'เงินเดือน': Color(0xFF4CAF50),   // เขียว
  'ค่าจ้าง': Color(0xFFE53935),     // แดง
  'โบนัส': Color(0xFF42A5F5),       // ฟ้า sky
  'ดอกเบี้ย': Color(0xFFFFEB3B),   // เหลือง
  'พาร์ทไทม์': Color(0xFFE91E63),  // ชมพู
  'OT': Color(0xFF7E57C2),          // ม่วง
  'หุ้น': Color(0xFF2ECCB6),        // เขียวมินท์
  'เงินออม': Color(0xFFFF9800),    // ส้ม
  'อื่นๆ': Color(0xFF90A4AE),       // เทา
};

const List<String> kIncomeCategories = [
  'เงินเดือน',
  'ค่าจ้าง',
  'โบนัส',
  'ดอกเบี้ย',
  'พาร์ทไทม์',
  'OT',
  'หุ้น',
  'เงินออม',
  'อื่นๆ',
];

/// สีรวม (ค้นจากชื่อหมวด)
Color catColor(String category) {
  if (_expenseColors.containsKey(category)) return _expenseColors[category]!;
  if (_incomeColors.containsKey(category)) return _incomeColors[category]!;
  return const Color(0xFF90A4AE);
}

/// ไอคอนตามหมวด
IconData catIcon(String category) {
  // รายจ่าย
  switch (category) {
    case 'อาหาร':
      return Icons.restaurant;
    case 'เดินทาง':
      return Icons.directions_bus;
    case 'ช้อปปิ้ง':
      return Icons.shopping_bag;
    case 'บิล':
      return Icons.receipt_long;
    case 'นันทนาการ':
      return Icons.celebration;
    case 'ยา':
      return Icons.medical_services;
    case 'ความงาม':
      return Icons.brush;
    case 'สังคม':
      return Icons.groups;
  }

  // รายรับ
  switch (category) {
    case 'เงินเดือน':
      return Icons.wallet; // หรือ Icons.paid
    case 'ค่าจ้าง':
      return Icons.work_outline;
    case 'โบนัส':
      return Icons.emoji_events;
    case 'ดอกเบี้ย':
      return Icons.savings; // ออม/ดอกเบี้ย
    case 'พาร์ทไทม์':
      return Icons.schedule;
    case 'OT':
      return Icons.access_time_filled;
    case 'หุ้น':
      return Icons.trending_up;
    case 'เงินออม':
      return Icons.account_balance_wallet;
    case 'อื่นๆ':
      return Icons.category;
  }

  return Icons.category;
}
