import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User

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
        return res = "Vui lòng nhập đầy đủ thông tin"; // Lỗi nhập thiếu
      }

      if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$").hasMatch(email)) {
        return res = "Vui lòng nhập đúng định dạng email"; // Email sai định dạng
      }

      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // for sighout
  signOut() async {
    await _auth.signOut();
  }

}

