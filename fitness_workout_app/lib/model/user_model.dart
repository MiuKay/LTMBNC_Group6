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
  });

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
    );
  }
}
