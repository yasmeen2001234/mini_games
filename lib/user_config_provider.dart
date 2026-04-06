import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserConfigProvider extends ChangeNotifier {
  String userName = "yasmeen"; // Default name
  int selectedAvatarIndex = 1; // Default avatar

  void updateName(String newName) {
    userName = newName;
    notifyListeners();
  }

  void updateAvatar(int newIndex) {
    // Wrap around for simplicity (skribbl style)
    if (newIndex >= 5) {
      selectedAvatarIndex = 0;
    } else if (newIndex < 0) {
      selectedAvatarIndex = 4;
    } else {
      selectedAvatarIndex = newIndex;
    }
    notifyListeners();
  }
}
