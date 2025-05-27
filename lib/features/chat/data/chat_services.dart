import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DataProvider dataProvider = DataProvider();

  Stream<List<String>> getChatsStream() {
    final uid = dataProvider.uid;

    if (uid == null) return const Stream.empty();

    return _firestore.collection('users_teachers').doc(uid).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) return <String>[];
      final List<dynamic> chats = data['chats'] ?? [];
      print(chats.toList());
      return chats.cast<String>();
    });
  }
}
