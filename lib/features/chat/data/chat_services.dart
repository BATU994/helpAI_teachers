import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getChatsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users_teachers')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return [];
          return List<String>.from(data['chats'] ?? []);
        });
  }
}
