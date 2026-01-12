import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../../services/follow_service.dart';
import '../../services/like_service.dart';
import '../../services/comment_service.dart';
import '../../services/save_service.dart';
import '../../models/post_model.dart';
import 'reels_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AuthService _auth;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FaithConnect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Explore Leaders',
            onPressed: () {
              Navigator.pushNamed(context, '/leaders');
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'My Leaders',
            onPressed: () {
              Navigator.pushNamed(context, '/myLeaders');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'Following'),
            Tab(text: 'Reels'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ExploreTab(),
          _FollowingTab(),
          ReelsFeedScreen(),
        ],
      ),
    );
  }
}

/// Explore: all posts from all leaders
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    final postService = PostService();
    return StreamBuilder<List<PostModel>>(
      stream: postService.getAllPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load posts. Please try again later.'),
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
            return _PostCard(post: p);
          },
        );
      },
    );
  }
}

/// Following: posts only from leaders the worshiper follows
class _FollowingTab extends StatelessWidget {
  const _FollowingTab();

  @override
  Widget build(BuildContext context) {
    final followService = FollowService();
    final db = FirebaseFirestore.instance;

    return StreamBuilder<List<String>>(
      stream: followService.followedLeaderIds(),
      builder: (context, followSnap) {
        if (followSnap.hasError) {
          return const Center(
            child: Text('Failed to load following list.'),
          );
        }

        if (!followSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaderIds = followSnap.data!;
        if (leaderIds.isEmpty) {
          return const Center(
            child: Text('Follow leaders to see their posts here'),
          );
        }

        final limitedIds = leaderIds.take(10).toList();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db
              .collection('posts')
              .where('leaderId', whereIn: limitedIds)
              // no orderBy here; sort in Dart to avoid composite index
              .snapshots(),
          builder: (context, postSnap) {
            if (postSnap.hasError) {
              return const Center(
                child: Text('Failed to load posts from followed leaders.'),
              );
            }

            if (!postSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = postSnap.data!.docs;
            if (docs.isEmpty) {
              return const Center(
                child: Text('No posts from followed leaders yet'),
              );
            }

            final posts = docs
                .map((d) => PostModel.fromMap(d.data(), d.id))
                .toList()
              ..sort((a, b) =>
                  b.createdAt.millisecondsSinceEpoch
                      .compareTo(a.createdAt.millisecondsSinceEpoch));

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = posts[i];
                return _PostCard(post: p);
              },
            );
          },
        );
      },
    );
  }
}

/// Post card with Like, Comment, Save, "Share" (snackbar)
class _PostCard extends StatelessWidget {
  final PostModel post;

  const _PostCard({required this.post});

  void _showCommentsSheet(BuildContext context) {
    final commentService = CommentService();
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: commentService.commentsForPost(post.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('No comments yet'));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final data = docs[i].data();
                          return ListTile(
                            title: Text(data['text'] ?? ''),
                            subtitle: Text(data['userEmail'] ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          await commentService.addComment(
                            post.id,
                            controller.text,
                          );
                          controller.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final likeService = LikeService();
    final saveService = SaveService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 8),
            Row(
              children: [
                // Like
                StreamBuilder<bool>(
                  stream: likeService.isLiked(post.id),
                  builder: (context, snapshot) {
                    final liked = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : null,
                      ),
                      onPressed: () {
                        likeService.toggleLike(post.id);
                      },
                    );
                  },
                ),
                // Comment
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _showCommentsSheet(context),
                ),
                // Save
                StreamBuilder<bool>(
                  stream: saveService.isSaved(post.id),
                  builder: (context, snapshot) {
                    final saved = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: () {
                        saveService.toggleSave(post.id);
                      },
                    );
                  },
                ),
                // "Share" – simple snackbar (no share_plus)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share is not implemented in this demo.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}