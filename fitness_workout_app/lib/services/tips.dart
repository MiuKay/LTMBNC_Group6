import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../model/exercise_model.dart';
import '../model/step_exercise_model.dart';
import '../model/tip_model.dart';

class TipsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Tip>> fetchStips() async {
    List<Tip> tipsList = [];

    try {
      QuerySnapshot tipsSnapshot = await _firestore
          .collection('Tips')
          .get();

      // Chuyển đổi mỗi tài liệu thành đối tượng Stips và thêm vào danh sách
      for (var stipsDoc in tipsSnapshot.docs) {
        tipsList.add(Tip.fromFirestore(stipsDoc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Error fetching Stips: $e");
    }
    print("Error fetching Stips: $tipsList");
    return tipsList;
  }

}