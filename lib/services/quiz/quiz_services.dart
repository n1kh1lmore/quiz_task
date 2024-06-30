import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/questions_model.dart';

class QuizService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Question>> getQuestions() async {
    try {
      var snapshot = await _firestore.collection('Test').get();
      return snapshot.docs.map((doc) => Question.fromJson(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

    Future<int> getLastScore(String userId) async {
    try {
      var snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data()?['score'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching last score: $e');
      }
      return 0;
    }
  }
}
