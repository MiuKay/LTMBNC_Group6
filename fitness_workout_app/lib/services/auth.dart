import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/model/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signupUser({
    required String email,
    required String password,
    required String fname,
    required String lname,
  }) async {
    String res = "Có lỗi gì đó xảy ra";
    try {
      if (email.isEmpty || password.isEmpty ||
          fname.isEmpty || lname.isEmpty) {
        return res = "Vui lòng điền đầy đủ thông tin"; // Lỗi nhập thiếu
      }

      if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$").hasMatch(email)) {
        return res ="Vui lòng điền đúng định dạng email"; // Email sai định dạng
      }

      if (email.isNotEmpty ||
          password.isNotEmpty ||
          fname.isNotEmpty || lname.isNotEmpty) {
        // register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // add user to your  firestore database
        print(cred.user!.uid);
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'fname': fname,
          'lname': lname,
          'uid': cred.user!.uid,
          'email': email,
        });

        res = "success";
      }
    }  on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = 'Email đã được sử dụng.';
      } else if (e.code == 'weak-password') {
        res = 'Mật khẩu quá yếu.';
      } else {
        res = e.message ?? 'Đã xảy ra lỗi không xác định.';
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }


  // logIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Có lỗi xảy ra";
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Vui lòng nhập đầy đủ thông tin"; // Lỗi nhập thiếu
      }

      if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$").hasMatch(email)) {
        return "Vui lòng nhập đúng định dạng email"; // Email sai định dạng
      }

      // Đăng nhập người dùng bằng email và mật khẩu
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } catch (error) {
      if (error is FirebaseAuthException) {
        // Kiểm tra mã lỗi của Firebase
        switch (error.code) {
          case 'invalid-email':
            return "Email không hợp lệ.";
          case 'user-disabled':
            return "Tài khoản của bạn đã bị vô hiệu hóa.";
          case 'user-not-found':
            return "Không tìm thấy tài khoản với email này.";
          case 'wrong-password':
            return "Mật khẩu không đúng.";
          case 'operation-not-allowed':
            return "Đăng nhập bằng email và mật khẩu không được phép.";
          default:
            return "Có lỗi xảy ra. Vui lòng thử lại.";
        }
      } else {
        return res; // Lỗi không xác định
      }
    }
  }

  // for sighout
  logOut() async {
    await _auth.signOut();
  }

  Future<String> completeUserProfile({
    required String uid,
    required String dateOfBirth,
    required String gender,
    required String weight,
    required String height,
  }) async {
    String res = "Có lỗi gì đó xảy ra";
    String pic = "";

    if (dateOfBirth.isEmpty || gender.isEmpty || weight.isEmpty || height.isEmpty) {
      return "Vui lòng điền đầy đủ thông tin.";
    }

    if (double.tryParse(weight) == null || double.parse(weight) <= 30) {
      return "Cân nặng phải là số và lớn hơn 30.";
    }

    if (double.tryParse(height) == null || double.parse(height) <= 50 || double.parse(height) >= 300) {
      return "Chiều cao phải là số và lớn hơn 50 và nhỏ hơn 300.";
    }

    try {
      await _firestore.collection("users").doc(uid).update({
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'weight': weight,
        'height': height,
        'pic': pic,
      });
      res = "success";
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<UserModel?> getUserInfo(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

}

