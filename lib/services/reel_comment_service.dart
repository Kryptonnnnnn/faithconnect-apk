import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReelCommentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> commentsForReel(
      String reelId) {
    return _db
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addComment(String reelId, String text) async {
    if (_uid == null || text.trim().isEmpty) return;
    final user = _auth.currentUser!;

    await _db
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .add({
      'userId': _uid,
      'userEmail': user.email,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}