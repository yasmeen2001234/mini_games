import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId = "global_room"; // Simplified for this example
  final String userId =
      "user_${Random().nextInt(1000)}"; // Unique ID for session

  HSLColor baseColor = HSLColor.fromAHSL(1.0, 200, 0.5, 0.5);
  int correctIndex = 0;
  double difficulty = 0.1; // Difference in lightness

  GameProvider() {
    _generateNewRound();
  }

  void _generateNewRound() {
    final random = Random();
    baseColor = HSLColor.fromAHSL(
      1.0,
      random.nextDouble() * 360,
      0.4 + random.nextDouble() * 0.4,
      0.4 + random.nextDouble() * 0.4,
    );
    correctIndex = random.nextInt(6);
    notifyListeners();
  }

  Future<void> handleTap(int index) async {
    if (index == correctIndex) {
      // Update local UI immediately for responsiveness
      _generateNewRound();

      // Update Firebase score
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(userId)
          .set({
            'name': 'Player $userId',
            'score': FieldValue.increment(5),
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  Stream<QuerySnapshot> get leaderboardStream => _firestore
      .collection('rooms')
      .doc(roomId)
      .collection('players')
      .orderBy('score', descending: true)
      .snapshots();
}
