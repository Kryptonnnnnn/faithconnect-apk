import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/reel_service.dart';
import '../../services/reel_like_service.dart';
import '../../services/reel_comment_service.dart';
import '../../services/reel_save_service.dart';

class ReelsFeedScreen extends StatelessWidget {
  const ReelsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ReelService();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.reelsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load reels. Please try again later.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No reels yet'));
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data();
            final reelId = docs[i].id;
            final url = data['videoUrl'] as String? ?? '';
            final caption = data['caption'] as String? ?? '';

            if (url.isEmpty) {
              return const Center(child: Text('Invalid reel URL'));
            }

            return ReelPlayer(
              reelId: reelId,
              videoUrl: url,
              caption: caption,
            );
          },
        );
      },
    );
  }
}

class ReelPlayer extends StatefulWidget {
  final String reelId;
  final String videoUrl;
  final String caption;

  const ReelPlayer({
    super.key,
    required this.reelId,
    required this.videoUrl,
    required this.caption,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  final _likeService = ReelLikeService();
  final _commentService = ReelCommentService();
  final _saveService = ReelSaveService();

  void _showCommentsSheet() {
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
                    stream: _commentService.commentsForReel(widget.reelId),
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
                          await _commentService.addComment(
                            widget.reelId,
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
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            _controller
              ..play()
              ..setLooping(true);
            if (mounted) {
              setState(() => _initialized = true);
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // video
        Positioned.fill(
          child: _initialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        // caption bar
        Positioned(
          left: 0,
          right: 60,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black38,
            child: Text(
              widget.caption,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        // actions column
        Positioned(
          right: 8,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like
              StreamBuilder<bool>(
                stream: _likeService.isLiked(widget.reelId),
                builder: (context, snapshot) {
                  final liked = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      _likeService.toggleLike(widget.reelId);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              // Comment
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _showCommentsSheet,
              ),
              const SizedBox(height: 8),
              // Save
              StreamBuilder<bool>(
                stream: _saveService.isSaved(widget.reelId),
                builder: (context, snapshot) {
                  final saved = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      _saveService.toggleSave(widget.reelId);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              // "Share" – snackbar only
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Share is not implemented in this demo.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}