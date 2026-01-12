import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../services/follow_service.dart';
import '../../services/post_service.dart';

class LeaderProfileScreen extends StatelessWidget {
  final String leaderId;

  const LeaderProfileScreen({super.key, required this.leaderId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final followService = FollowService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leader Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Posts'),
              Tab(text: 'Reels'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: db.collection('users').doc(leaderId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = snapshot.data!.data();
                if (data == null) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Leader not found'),
                  );
                }

                final name = data['name'] as String? ?? '';
                final faith = data['faith'] as String? ?? '';
                final bio = data['bio'] as String? ?? '';
                final photoUrl = data['photoUrl'] as String? ?? '';

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (faith.isNotEmpty)
                              Text(
                                faith,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (bio.isNotEmpty)
                              Text(
                                bio,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                StreamBuilder<bool>(
                                  stream: followService.isFollowing(leaderId),
                                  builder: (context, snap) {
                                    final isFollowing = snap.data ?? false;
                                    return ElevatedButton(
                                      onPressed: () {
                                        if (isFollowing) {
                                          followService.unfollowLeader(leaderId);
                                        } else {
                                          followService.followLeader(leaderId);
                                        }
                                      },
                                      child: Text(
                                        isFollowing ? 'Following' : 'Follow',
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/chat',
                                      arguments: leaderId,
                                    );
                                  },
                                  icon: const Icon(Icons.message),
                                  label: const Text('Message'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 1),

            Expanded(
              child: TabBarView(
                children: [
                  _LeaderPostsTab(leaderId: leaderId),
                  _LeaderReelsTab(leaderId: leaderId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderPostsTab extends StatelessWidget {
  final String leaderId;
  const _LeaderPostsTab({required this.leaderId});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return StreamBuilder<List<PostModel>>(
      stream: postService.getPostsForLeader(leaderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load posts for this leader.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final p = posts[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p.content),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LeaderReelsTab extends StatelessWidget {
  final String leaderId;
  const _LeaderReelsTab({required this.leaderId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db
          .collection('reels')
          .where('leaderId', isEqualTo: leaderId)
          // no orderBy -> no composite index needed
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load reels for this leader.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No reels yet'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final data = docs[i].data();
            final caption = data['caption'] as String? ?? '';
            return ListTile(
              leading: const Icon(Icons.play_circle_fill),
              title: Text(caption.isEmpty ? 'Reel' : caption),
              subtitle: const Text('Watch in the main Reels tab'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Open the Reels tab on Home to watch this reel.'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}