import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId = "global_room"; // Simplified for this example
  final String userId =
      "user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}"; // Unique ID for session

  String playerName = "Player"; // Will be set from SetupScreen
  String playerAvatar = "🧐"; // Will be set from SetupScreen
  HSLColor baseColor = HSLColor.fromAHSL(1.0, 200, 0.5, 0.5);
  int correctIndex = 0;
  double difficulty = 0.1; // Difference in lightness

  GameProvider() {
    print('🆕 GameProvider created with userId: $userId');
    _generateNewRound();
  }

  void setPlayerName(String name) {
    playerName = name.isNotEmpty ? name : "Player";
    notifyListeners();
  }

  void setPlayerAvatar(String avatar) {
    playerAvatar = avatar;
    notifyListeners();
    // Initialize player document in Firestore
    _initializePlayerDocument();
  }

  Future<void> _initializePlayerDocument() async {
    try {
      print(
        '🎮 Initializing player: $userId, name: $playerName, avatar: $playerAvatar',
      );
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(userId)
          .set({
            'name': playerName,
            'avatar': playerAvatar,
            'score': 0,
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      print('✅ Player initialized successfully');
    } catch (e) {
      print('❌ Error initializing player document: $e');
    }
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
            'name': playerName,
            'avatar': playerAvatar,
            'score': FieldValue.increment(5),
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  Stream<QuerySnapshot> get leaderboardStream {
    print('📊 Leaderboard stream requested from room: $roomId');
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .orderBy('score', descending: true)
        .snapshots();
  }
}
