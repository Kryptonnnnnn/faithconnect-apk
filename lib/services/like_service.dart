import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  String _likeDocId(String postId, String userId) => '${postId}_$userId';

  Stream<bool> isLiked(String postId) {
    if (_uid == null) return Stream<bool>.value(false);
    final docId = _likeDocId(postId, _uid!);
    return _db.collection('postLikes').doc(docId).snapshots().map((snap) {
      return snap.exists;
    });
  }

  Future<void> toggleLike(String postId) async {
    if (_uid == null) return;
    final userId = _uid!;
    final likeId = _likeDocId(postId, userId);
    final likeRef = _db.collection('postLikes').doc(likeId);
    final postRef = _db.collection('posts').doc(postId);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);
      final currentCount = (postSnap.data()?['likesCount'] as int?) ?? 0;

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likesCount': currentCount - 1});
      } else {
        tx.set(likeRef, {
          'postId': postId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(postRef, {'likesCount': currentCount + 1});
      }
    });
  }
}