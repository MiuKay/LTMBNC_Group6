import 'package:flutter/material.dart';
import '../common/colo_extension.dart';
import '../model/tip_model.dart';

class TipRow extends StatelessWidget {
  final Tip tObj;
  final VoidCallback onPressed;
  final bool isActive;
  const TipRow({super.key, required this.tObj, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? TColor.lightGray.withOpacity(0.2) : Colors.transparent, // Đổi màu nền khi active
          borderRadius: BorderRadius.circular(10), // Bo góc cho container
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                tObj.name,
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis, // Cắt ngắn văn bản nếu quá dài
                maxLines: 1, // Giới hạn hiển thị trong 1 dòng
              ),
            ),
            SizedBox(width: 10), // Tạo khoảng cách giữa Text và Image
            Icon(
              Icons.arrow_forward_ios, // Sử dụng biểu tượng mũi tên thay thế hình ảnh
              size: 20,
              color: TColor.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
