class Tip {
  final String detail;
  final String name;
  final String pic;

  Tip({
    required this.detail,
    required this.name,
    required this.pic,
  });

  // Factory method để tạo một đối tượng Stips từ một document của Firestore
  factory Tip.fromJson(Map<String, dynamic> data) {
    return Tip(
      detail: data['detail'] ?? '',
      name: data['name'] ?? '',
      pic: data['pic'] ?? '',
    );
  }

  // Phương thức để chuyển đổi đối tượng Stips thành Map cho Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'details': detail,
      'name': name,
      'pic': pic,
    };
  }
}
