import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final authService = AuthService();
    final db = FirebaseFirestore.instance;
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chatService.myChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chatData = chats[index].data();
              final participants =
                  List<String>.from(chatData['participants'] ?? []);
              if (currentUser == null || participants.length < 2) {
                return const SizedBox.shrink();
              }

              // find the "other" participant in this chat
              final otherId = participants
                  .firstWhere((id) => id != currentUser.uid, orElse: () => '');

              if (otherId.isEmpty) return const SizedBox.shrink();

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: db.collection('users').doc(otherId).get(),
                builder: (context, userSnap) {
                  final userData = userSnap.data?.data();
                  final name = userData?['name'] as String? ?? 'User';
                  final faith = userData?['faith'] as String? ?? '';
                  final photoUrl = userData?['photoUrl'] as String? ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                          : null,
                    ),
                    title: Text(name),
                    subtitle: faith.isNotEmpty ? Text(faith) : null,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: otherId,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}