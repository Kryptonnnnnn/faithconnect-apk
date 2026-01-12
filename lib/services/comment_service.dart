import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> commentsForPost(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addComment(String postId, String text) async {
    if (_uid == null || text.trim().isEmpty) return;
    final user = _auth.currentUser!;

    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': _uid,
      'userEmail': user.email,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}