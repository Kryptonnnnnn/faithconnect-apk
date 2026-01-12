import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/follow_service.dart';

class MyLeadersScreen extends StatelessWidget {
  const MyLeadersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final followService = FollowService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Leaders')),
      body: StreamBuilder<List<String>>(
        stream: followService.followedLeaderIds(),
        builder: (context, followSnap) {
          if (!followSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final leaderIds = followSnap.data!;
          if (leaderIds.isEmpty) {
            return const Center(child: Text('You are not following anyone yet'));
          }

          // Firestore whereIn supports up to 10 items; in a prototype that’s OK.
          final limitedIds = leaderIds.take(10).toList();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: db
                .collection('users')
                .where('uid', whereIn: limitedIds)
                .snapshots(),
            builder: (context, userSnap) {
              if (!userSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = userSnap.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No leaders found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final leaderId = data['uid'] as String;
                  final name = data['name'] as String? ?? '';
                  final faith = data['faith'] as String? ?? '';
                  final bio = data['bio'] as String? ?? '';
                  final photoUrl = data['photoUrl'] as String? ?? '';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                              )
                            : null,
                      ),
                      title: Text(name),
                      subtitle: Text(
                        faith.isNotEmpty ? '$faith • $bio' : bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.message),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: leaderId,
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/leaderProfile',
                          arguments: leaderId,
                        );
                      },
                    ),
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