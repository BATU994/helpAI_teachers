import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';
import 'package:helpai_teachers/features/chat/data/chat_services.dart';
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
        print(chats.toList());
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
          return const ListTile(title: Text('Loading chat...'));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(title: Text('Error loading chat'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUserId = participants.firstWhere(
          (id) => id != currentUid,
          orElse: () => '',
        );

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users_teachers')
                  .doc(otherUserId)
                  .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(title: Text('Loading user...'));
            }
            if (userSnapshot.hasError ||
                !userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatPage(
                            otherUserId: otherUserId,
                            chatId: chatId,
                          ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textColor: Colors.white,
                tileColor: Colors.blue,
                title: Text('Chat with: $otherUserId'),
              );
            }
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final userName = userData['firstName'] ?? 'Unknown';
            return InkWell(
              onTap: () {},
              child: ListTile(
                title: Text('Chat with: $userName'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatPage(
                            chatId: chatId,
                            otherUserId: otherUserId,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
