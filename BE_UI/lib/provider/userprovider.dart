import 'package:be_ui/model/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> updates) {
    if (_user != null) {
      _user = User(
        id: updates['id'] ?? _user!.id,
        name: updates['name'] ?? _user!.name,
        email: updates['email'] ?? _user!.email,
        role: updates['role'] ?? _user!.role,
        phone: updates['phone'] ?? _user!.phone,
        badgeNumber: updates['badgeNumber'] ?? _user!.badgeNumber,
        department: updates['department'] ?? _user!.department,
      );
      notifyListeners();
    }
  }
}
