import 'package:intl/intl.dart';

class UserModel {
  final String uid;
  final String fname;
  final String lname;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String weight;
  final String height;
  final String pic;
  final String level;

  UserModel({
    required this.uid,
    required this.fname,
    required this.lname,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.weight,
    required this.height,
    required this.pic,
    required this.level
  });

  // Tính tuổi người dùng từ ngày sinh
  int getAge() {
    // Sử dụng DateFormat để parse chuỗi ngày tháng
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime dob = dateFormat.parse(dateOfBirth);
    DateTime today = DateTime.now();

    int age = today.year - dob.year;

    // Nếu chưa đến ngày sinh nhật trong năm nay, thì trừ 1 tuổi
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  // Bạn có thể thêm phương thức từ JSON nếu cần
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      weight: json['weight'],
      height: json['height'],
      pic: json['pic'],
      level: json['level'],
    );
  }
}

