import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'GameProvider.dart';
import 'package:provider/provider.dart';

class HSLGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      body: Row(
        children: [
          // Left Sidebar: Leaderboard
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Leaderboard",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: LeaderboardWidget()),
              ],
            ),
          ),
          // Main Game Area
          Expanded(child: GameArea()),
        ],
      ),
    );
  }
}

class GameArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "HSL Color Game",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              "Find the block with a different shade.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                bool isCorrect = index == game.correctIndex;
                Color blockColor = isCorrect
                    ? game.baseColor
                          .withLightness(
                            (game.baseColor.lightness + 0.1).clamp(0.0, 1.0),
                          )
                          .toColor()
                    : game.baseColor.toColor();

                return GestureDetector(
                  onTap: () => game.handleTap(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);

    return Column(
      children: [
        // Current Player Profile
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                  child: Text(
                    game.playerAvatar,
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.playerName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Your Score",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: game.leaderboardStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Text("0");

                    int playerScore = 0;
                    try {
                      var playerDoc = snapshot.data!.docs.firstWhere(
                        (doc) => doc.id == game.userId,
                      );
                      playerScore = playerDoc['score'] ?? 0;
                    } catch (e) {
                      playerScore = 0;
                    }

                    return Text(
                      "$playerScore",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Top Players",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: LeaderboardList()),
      ],
    );
  }
}

class LeaderboardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
      stream: game.leaderboardStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('❌ Leaderboard error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Leaderboard loading...');
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('⚠️ No players found in leaderboard');
          return Center(
            child: Text(
              'No players yet',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        print(
          '✅ Leaderboard updated with ${snapshot.data!.docs.length} players',
        );
        for (var doc in snapshot.data!.docs) {
          print('   - ${doc['name']}: ${doc['score']} pts');
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            String avatar = data['avatar'] ?? '🧐';
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 1),
                ),
                child: Text(avatar, style: TextStyle(fontSize: 20)),
              ),
              title: Text(data['name'] ?? 'Unknown'),
              trailing: Text(
                "${data['score'] ?? 0}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }
}
