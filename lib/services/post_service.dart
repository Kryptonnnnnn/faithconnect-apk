import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// CREATE POST (Leader)
  Future<void> createPost({
    required String title,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'leaderId': user.uid,
      'createdAt': Timestamp.now(),
    });
  }

  /// STREAM ALL POSTS (Home → Explore)
  Stream<List<PostModel>> getAllPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// STREAM POSTS FOR A SPECIFIC LEADER (Home → Following, Leader profile)
  Stream<List<PostModel>> getPostsForLeader(String leaderId) {
    return _db
        .collection('posts')
        .where('leaderId', isEqualTo: leaderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}