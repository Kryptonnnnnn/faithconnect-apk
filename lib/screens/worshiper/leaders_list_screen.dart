import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/follow_service.dart';

class LeadersListScreen extends StatelessWidget {
  const LeadersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final followService = FollowService();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Leaders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // SIMPLER QUERY: no orderBy -> no composite index
        stream: db
            .collection('users')
            .where('role', isEqualTo: 'leader')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load leaders. Please try again later.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No leaders yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final leaderId = data['uid'] as String? ?? '';
              final name = data['name'] as String? ?? '';
              final faith = data['faith'] as String? ?? '';
              final bio = data['bio'] as String? ?? '';
              final photoUrl = data['photoUrl'] as String? ?? '';

              if (leaderId.isEmpty) {
                return const SizedBox.shrink();
              }

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
                  trailing: StreamBuilder<bool>(
                    stream: followService.isFollowing(leaderId),
                    builder: (context, snap) {
                      final isFollowing = snap.data ?? false;
                      return TextButton(
                        onPressed: () {
                          if (isFollowing) {
                            followService.unfollowLeader(leaderId);
                          } else {
                            followService.followLeader(leaderId);
                          }
                        },
                        child: Text(isFollowing ? 'Following' : 'Follow'),
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
      ),
    );
  }
}