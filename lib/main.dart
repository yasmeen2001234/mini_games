import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_config_provider.dart'; // Import the provider above
import 'GameProvider.dart';
import 'SetupScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mapping your firebaseConfig to Flutter's FirebaseOptions
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCTI1yvypKj9i9yupZJxWu6t_5gernXW1c",
      authDomain: "mini-games-29ed1.firebaseapp.com",
      projectId: "mini-games-29ed1",
      storageBucket: "mini-games-29ed1.firebasestorage.app",
      messagingSenderId: "1030980374727",
      appId: "1:1030980374727:web:b20639bc598e929702eee2",
      measurementId: "G-7Q2ZQ259GY",
    ),
  );

  runApp(
    MultiProvider(
      // Change to MultiProvider
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserConfigProvider(),
        ), // New Provider
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSL Color Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: SetupScreen(),
    );
  }
}

// --- UI COMPONENTS ---
class HSLGameScreen extends StatelessWidget {
  const HSLGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Leaderboard
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const LeaderboardWidget(),
          ),
          // Game Center
          const Expanded(child: GameArea()),
        ],
      ),
    );
  }
}

class GameArea extends StatelessWidget {
  const GameArea({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "HSL Color Game",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text("Find the different shade!"),
          const SizedBox(height: 30),
          SizedBox(
            width: 400,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final isCorrect = index == game.correctIndex;
                final color = isCorrect
                    ? game.baseColor
                          .withLightness(
                            (game.baseColor.lightness + 0.1).clamp(0.0, 1.0),
                          )
                          .toColor()
                    : game.baseColor.toColor();

                return GestureDetector(
                  onTap: () => game.handleTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = Provider.of<GameProvider>(
      context,
      listen: false,
    ).leaderboardStream;

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: Text("Loading..."));
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(docs[i]['name'], style: const TextStyle(fontSize: 12)),
            trailing: Text("${docs[i]['score']}"),
          ),
        );
      },
    );
  }
}
