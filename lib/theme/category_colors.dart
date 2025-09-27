import 'package:flutter/material.dart';

/// สีสำหรับรายจ่าย (Expense)
const Map<String, Color> kExpenseColors = {
  'อาหาร': Color(0xFFFFA726),        // ส้ม
  'เดินทาง': Color(0xFF42A5F5),      // ฟ้า sky
  'ช็อปปิ้ง': Color(0xFFF06292),     // ชมพู
  'บิล': Color(0xFFAB47BC),          // ม่วง
  'นันทนาการ': Color(0xFFFFEB3B),   // เหลือง
  'ยา': Color(0xFF66BB6A),           // เขียว
  'ความงาม': Color(0xFF26C6DA),      // มินท์ (ฟ้าอมเขียว)
  'สังคม': Color(0xFF1E88E5),        // น้ำเงิน
  'อื่นๆ': Color(0xFF9E9E9E),        // เทา
};

/// ไอคอนรายจ่าย
const Map<String, IconData> kExpenseIcons = {
  'อาหาร': Icons.restaurant_outlined,
  'เดินทาง': Icons.directions_bus_outlined,
  'ช็อปปิ้ง': Icons.shopping_bag_outlined,
  'บิล': Icons.receipt_long_outlined,
  'นันทนาการ': Icons.sports_esports_outlined,
  'ยา': Icons.medication_outlined,
  'ความงาม': Icons.brush_outlined,
  'สังคม': Icons.groups_outlined,
  'อื่นๆ': Icons.category_outlined,
};

/// สีสำหรับรายรับ (Income)
const Map<String, Color> kIncomeColors = {
  'เงินเดือน': Color(0xFF66BB6A),     // เขียว
  'ค่าจ้าง': Color(0xFFE57373),       // แดง
  'โบนัส': Color(0xFF42A5F5),         // ฟ้า sky
  'ดอกเบี้ย': Color(0xFFFFEB3B),     // เหลือง
  'พาร์ทไทม์': Color(0xFFF06292),    // ชมพู
  'OT': Color(0xFFAB47BC),            // ม่วง
  'หุ้น': Color(0xFF26C6DA),          // เขียวมินท์
  'เงินออม': Color(0xFFFFA726),      // ส้ม
  'อื่นๆ': Color(0xFF9E9E9E),         // เทา
};

/// ไอคอนรายรับ
const Map<String, IconData> kIncomeIcons = {
  'เงินเดือน': Icons.card_giftcard_outlined,
  'ค่าจ้าง': Icons.work_outline,
  'โบนัส': Icons.stars_outlined,
  'ดอกเบี้ย': Icons.savings_outlined,
  'พาร์ทไทม์': Icons.timer_outlined,
  'OT': Icons.alarm_on_outlined,
  'หุ้น': Icons.show_chart_outlined,
  // ถ้า SDK เก่ากว่า ไม่มี piggy_bank ให้ใช้ savings แทน
  'เงินออม': Icons.savings_outlined,
  'อื่นๆ': Icons.wallet_outlined,
};

/// helper เลือกสีตามประเภท+หมวด
Color pickCategoryColor(String type, String category) {
  if (type == 'income') {
    return kIncomeColors[category] ?? Colors.grey;
  }
  return kExpenseColors[category] ?? Colors.grey;
}

/// helper เลือกไอคอนตามประเภท+หมวด
IconData pickCategoryIcon(String type, String category) {
  if (type == 'income') {
    return kIncomeIcons[category] ?? Icons.attach_money_rounded;
  }
  return kExpenseIcons[category] ?? Icons.category_outlined;
}
