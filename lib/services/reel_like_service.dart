import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReelLikeService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  String _likeDocId(String reelId, String userId) => '${reelId}_$userId';

  Stream<bool> isLiked(String reelId) {
    if (_uid == null) return Stream<bool>.value(false);
    final docId = _likeDocId(reelId, _uid!);
    return _db.collection('reelLikes').doc(docId).snapshots().map((snap) {
      return snap.exists;
    });
  }

  Future<void> toggleLike(String reelId) async {
    if (_uid == null) return;
    final userId = _uid!;
    final likeId = _likeDocId(reelId, userId);
    final likeRef = _db.collection('reelLikes').doc(likeId);
    final reelRef = _db.collection('reels').doc(reelId);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final reelSnap = await tx.get(reelRef);
      final currentCount = (reelSnap.data()?['likesCount'] as int?) ?? 0;

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(reelRef, {'likesCount': currentCount - 1});
      } else {
        tx.set(likeRef, {
          'reelId': reelId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(reelRef, {'likesCount': currentCount + 1});
      }
    });
  }
}