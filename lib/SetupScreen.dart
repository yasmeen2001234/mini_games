import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_config_provider.dart'; // Import the provider above
import 'GameProvider.dart';
import 'mainscreen.dart';

class SetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define simple text/pixel art-style avatars like Skribbl (e.g., Unicode symbols or basic graphics)
    final List<String> avatars = ["🧐", "🐱", "🐶", "👽", "🦄"];
    final userConfig = Provider.of<UserConfigProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFE0E6EF), // Soft, minimalist background
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              Text(
                "Welcome to the HSL Game!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Configure your profile.",
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 32),

              // NAME INPUT
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Enter your name",
                ),
                onChanged: (value) => userConfig.updateName(value),
              ),
              SizedBox(height: 32),

              // AVATAR SELECTION (SKRIBBL-STYLE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 36),
                    onPressed: () => userConfig.updateAvatar(
                      userConfig.selectedAvatarIndex - 1,
                    ),
                  ),
                  // Display the current avatar simply
                  Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange, // Friendly base color
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 2),
                    ),
                    child: Text(
                      avatars[userConfig.selectedAvatarIndex],
                      style: TextStyle(fontSize: 60), // Larger emoji/symbol
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 36),
                    onPressed: () => userConfig.updateAvatar(
                      userConfig.selectedAvatarIndex + 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48),

              // PLAY BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Get GameProvider and set the player name and avatar
                    final gameProvider = Provider.of<GameProvider>(
                      context,
                      listen: false,
                    );
                    gameProvider.setPlayerName(userConfig.userName);
                    gameProvider.setPlayerAvatar(
                      avatars[userConfig.selectedAvatarIndex],
                    );

                    // Initialize the GameProvider here and navigate!
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HSLGameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                      0xFF6EDD3C,
                    ), // Lime green, Skribbl-style
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Play!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
