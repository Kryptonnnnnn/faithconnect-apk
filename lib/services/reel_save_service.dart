import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReelSaveService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  String _docId(String reelId, String userId) => '${reelId}_$userId';

  Stream<bool> isSaved(String reelId) {
    if (_uid == null) return Stream<bool>.value(false);
    final id = _docId(reelId, _uid!);
    return _db.collection('savedReels').doc(id).snapshots().map((snap) {
      return snap.exists;
    });
  }

  Future<void> toggleSave(String reelId) async {
    if (_uid == null) return;
    final id = _docId(reelId, _uid!);
    final ref = _db.collection('savedReels').doc(id);

    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'reelId': reelId,
        'userId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}