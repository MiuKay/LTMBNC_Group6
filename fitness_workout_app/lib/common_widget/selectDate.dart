import 'package:flutter/material.dart';

class DatePickerHelper {
  // Hàm để hiển thị DatePicker
  static Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Ngày mặc định là ngày hiện tại
      firstDate: DateTime(1900),   // Giới hạn ngày bắt đầu
      lastDate: DateTime.now(),    // Giới hạn ngày kết thúc (ngày hiện tại)
    );
    if (picked != null) {
      // Cập nhật giá trị của TextEditingController với ngày đã chọn
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }
}
