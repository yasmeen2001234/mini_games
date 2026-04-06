import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mini_game/gameprovider.dart';
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

    return StreamBuilder<QuerySnapshot>(
      stream: game.leaderboardStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return ListTile(
              leading: CircleAvatar(child: Text("${index + 1}")),
              title: Text(data['name']),
              trailing: Text(
                "${data['score']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }
}
