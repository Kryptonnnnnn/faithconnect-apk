import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  String _docId(String postId, String userId) => '${postId}_$userId';

  Stream<bool> isSaved(String postId) {
    if (_uid == null) return Stream<bool>.value(false);
    final id = _docId(postId, _uid!);
    return _db.collection('savedPosts').doc(id).snapshots().map((snap) {
      return snap.exists;
    });
  }

  Future<void> toggleSave(String postId) async {
    if (_uid == null) return;
    final id = _docId(postId, _uid!);
    final ref = _db.collection('savedPosts').doc(id);

    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'postId': postId,
        'userId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}