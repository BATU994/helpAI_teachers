import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  static final DataProvider _instance = DataProvider._internal();
  factory DataProvider() => _instance;

  DataProvider._internal();
  String? _userName;
  String? _imageUrl;
  String? _firstName;
  String? _uid;
  String? get firstName => _firstName;
  String? get userName => _userName;
  String? get imageUrl => _imageUrl;
  String? get uid => _uid;

  Future<void> fetchAndSetUserData(String uid) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users_teachers')
            .doc(uid)
            .get();
    if (doc.exists) {
      final data = doc.data();
      _userName = data?['firstName'] + ' ' + data?['lastName'];
      _imageUrl = data?['imageUrl'];
      _firstName = data?['firstName'];
      _uid = data?['uid'];
      print('success');
      notifyListeners();
    } else {
      print('fail');
    }
  }
}
