import 'package:flutter/material.dart';

/// สีธีมหลัก
const peach = Color(0xFFFFF0E2);
const peachStrong = Color(0xFFE7B79C);

/// —— รายจ่าย ——
/// อาหาร=ส้ม, เดินทาง=ฟ้า, ช็อปปิ้ง=ชมพู, บิล=ม่วง,
/// นันทนาการ=เหลือง, ยา=เขียว, ความงาม=มินต์, สังคม=น้ำเงิน
const Map<String, Color> kExpenseColors = {
  'อาหาร': Color(0xFFFFA726),
  'เดินทาง': Color(0xFF42A5F5),
  'ช็อปปิ้ง': Color(0xFFFF6BB6),
  'บิล': Color(0xFFAB47BC),
  'นันทนาการ': Color(0xFFFFF176),
  'ยา': Color(0xFF66BB6A),
  'ความงาม': Color(0xFF2CD9C5),
  'สังคม': Color(0xFF1E88E5),
  'อื่นๆ': Color(0xFFBDBDBD),
};

const Map<String, IconData> kExpenseIcons = {
  'อาหาร': Icons.restaurant_outlined,
  'เดินทาง': Icons.directions_bus_outlined,
  'ช็อปปิ้ง': Icons.shopping_bag_outlined,
  'บิล': Icons.receipt_long_outlined,
  'นันทนาการ': Icons.celebration_outlined,
  'ยา': Icons.medical_services_outlined,
  'ความงาม': Icons.brush_outlined,
  'สังคม': Icons.groups_2_outlined,
  'อื่นๆ': Icons.category_outlined,
};

/// —— รายรับ —— (เพิ่มสี/ไอคอน)
const Map<String, Color> kIncomeColors = {
  'เงินเดือน': Color(0xFF43A047), // เขียว
  'ค่าจ้าง': Color(0xFFE53935),   // แดง
  'โบนัส': Color(0xFF42A5F5),     // blue sky
  'ดอกเบี้ย': Color(0xFFFFCA28), // เหลือง
  'พาร์ทไทม์': Color(0xFFFF6BB6),// ชมพู
  'OT': Color(0xFFAB47BC),        // ม่วง
  'หุ้น': Color(0xFF26C6DA),      // เขียวมินต์/ฟ้า
  'เงินออม': Color(0xFFFFA726),   // ส้ม
  'อื่นๆ': Color(0xFF9E9E9E),     // เทา
};

const Map<String, IconData> kIncomeIcons = {
  'เงินเดือน': Icons.card_giftcard_outlined,
  'ค่าจ้าง': Icons.work_outline,
  'โบนัส': Icons.stars_outlined,
  'ดอกเบี้ย': Icons.savings_outlined,
  'พาร์ทไทม์': Icons.timer_outlined,
  'OT': Icons.alarm_on_outlined,
  'หุ้น': Icons.show_chart_outlined,
  'เงินออม': Icons.savings_outlined, // ใช้ savings แทน piggy_bank เพื่อรองรับทุกเวอร์ชัน
  'อื่นๆ': Icons.wallet_outlined,
};

Color pickCategoryColor(String type, String category) =>
    (type == 'expense' ? kExpenseColors[category] : kIncomeColors[category]) ??
    const Color(0xFFBDBDBD);

IconData pickCategoryIcon(String type, String category) =>
    (type == 'expense' ? kExpenseIcons[category] : kIncomeIcons[category]) ??
    Icons.category_outlined;
