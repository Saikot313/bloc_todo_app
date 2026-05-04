
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'all_users';
  final _uuid = const Uuid();

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user already exists
    final usersJson = prefs.getString(_usersKey);
    final users = usersJson != null
        ? (jsonDecode(usersJson) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    final existingUser = users.where((u) => u['email'] == email).toList();
    if (existingUser.isNotEmpty) {
      throw Exception('এই email দিয়ে আগেই account আছে!');
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    // Save user credentials
    users.add({...user.toJson(), 'password': password});
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) {
      throw Exception('কোনো account নেই। প্রথমে Sign Up করুন।');
    }

    final users = (jsonDecode(usersJson) as List).cast<Map<String, dynamic>>();
    final matchingUsers = users.where(
      (u) => u['email'] == email && u['password'] == password,
    ).toList();

    if (matchingUsers.isEmpty) {
      throw Exception('Email বা Password ভুল!');
    }

    final userMap = Map<String, dynamic>.from(matchingUsers.first)..remove('password');
    final user = UserModel.fromJson(userMap);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
