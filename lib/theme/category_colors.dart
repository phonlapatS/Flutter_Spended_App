import 'package:flutter/material.dart';

// รายจ่าย
const Map<String, Color> kExpenseColors = {
  'อาหาร': Color(0xFFFFA726),      // ส้ม
  'เดินทาง': Color(0xFF42A5F5),    // ฟ้า sky blue
  'ช็อปปิ้ง': Color(0xFFFF6E6E),   // แดงชมพู
  'บิล': Color(0xFF8E24AA),        // ม่วง
  'นันทนาการ': Color(0xFFFFEB3B), // เหลือง
  'ยา': Color(0xFF66BB6A),         // เขียว
  'ความงาม': Color(0xFFFF80AB),    // มินท์/ชมพูอ่อน
  'สังคม': Color(0xFF1976D2),      // น้ำเงิน
};

// รายรับ
const Map<String, Color> kIncomeColors = {
  'เงินเดือน': Color(0xFF2E7D32),  // เขียว
  'ค่าจ้าง': Color(0xFFB71C1C),    // แดง
  'โบนัส': Color(0xFF42A5F5),      // ฟ้า
  'ดอกเบี้ย': Color(0xFFFFEB3B),  // เหลือง
  'พาร์ทไทม์': Color(0xFFFF80AB), // ชมพู
  'OT': Color(0xFF8E24AA),         // ม่วง
  'หุ้น': Color(0xFF26A69A),       // เขียวมินท์
  'เงินออม': Color(0xFFFFA726),    // ส้ม
  'อื่นๆ': Color(0xFF9E9E9E),      // เทา
};

// ไอคอน (ตัวอย่าง)
const Map<String, IconData> kCategoryIcons = {
  'อาหาร': Icons.restaurant_outlined,
  'เดินทาง': Icons.directions_car_outlined,
  'ช็อปปิ้ง': Icons.shopping_bag_outlined,
  'บิล': Icons.receipt_long_outlined,
  'นันทนาการ': Icons.celebration_outlined,
  'ยา': Icons.medical_services_outlined,
  'ความงาม': Icons.brush_outlined,
  'สังคม': Icons.groups_outlined,
};

const Map<String, IconData> kIncomeIcons = {
  'เงินเดือน': Icons.card_giftcard_outlined,
  'ค่าจ้าง': Icons.work_outline,
  'โบนัส': Icons.stars_outlined,
  'ดอกเบี้ย': Icons.savings_outlined,
  'พาร์ทไทม์': Icons.timer_outlined,
  'OT': Icons.alarm_on_outlined,          // ✅ มี OT
  'หุ้น': Icons.show_chart_outlined,
  'เงินออม': Icons.savings_outlined,
  'อื่นๆ': Icons.wallet_outlined,
};

// helper
Color pickCategoryColor(String type, String category) =>
    type == 'expense' ? (kExpenseColors[category] ?? Colors.grey) : (kIncomeColors[category] ?? Colors.grey);
IconData pickCategoryIcon(String type, String category) =>
    type == 'expense' ? (kCategoryIcons[category] ?? Icons.category_outlined) : (kIncomeIcons[category] ?? Icons.attach_money_rounded);
