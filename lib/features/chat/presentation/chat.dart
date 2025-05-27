import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';
import 'package:helpai_teachers/features/chat/data/chat_services.dart';
import 'package:helpai_teachers/features/chat/presentation/user_tile.dart';
import 'package:helpai_teachers/features/chat_page/presentation/chat_page.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatServices _chatServices = ChatServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: buildUsersInfo(),
    );
  }

  Widget buildUsersInfo() {
    return StreamBuilder<List<String>>(
      stream: _chatServices.getChatsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }
        final chats = snapshot.data ?? [];
        return ListView(
          children:
              chats
                  .map((chatData) => _buildUserListItem(chatData, context))
                  .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(String chatId, BuildContext context) {
    final currentUid = Provider.of<DataProvider>(context, listen: false).uid;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('chats').doc(chatId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text('Loading...'));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(title: Text('Error loading chat'));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUserId = participants[0];
        final otherUser =
            FirebaseFirestore.instance
                .collection('users_teachers')
                .doc(otherUserId)
                .get();
        return ListTile(
          title: Text('Chat with: $otherUserId'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ChatPage(chatId: chatId, otherUserId: otherUserId),
              ),
            );
          },
        );
      },
    );
  }
}
