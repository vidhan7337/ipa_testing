import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get user => _currentUser;
  String? get userId => _currentUser?.id;

  Future<void> loadCurentUser(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromMap(userDoc.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }
}
