import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Document ID pattern: "{worshiperId}_{leaderId}"
  String _docId(String worshiperId, String leaderId) =>
      '${worshiperId}_$leaderId';

  Future<void> followLeader(String leaderId) async {
    if (_uid == null) return;

    final docId = _docId(_uid!, leaderId);

    await _db.collection('follows').doc(docId).set({
      'worshiperId': _uid,
      'leaderId': leaderId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowLeader(String leaderId) async {
    if (_uid == null) return;
    final docId = _docId(_uid!, leaderId);
    await _db.collection('follows').doc(docId).delete();
  }

  /// Is current user following this leader?
  Stream<bool> isFollowing(String leaderId) {
    if (_uid == null) return Stream<bool>.value(false);
    final docId = _docId(_uid!, leaderId);
    return _db.collection('follows').doc(docId).snapshots().map((snap) {
      return snap.exists;
    });
  }

  /// All leader IDs that current worshiper follows
  Stream<List<String>> followedLeaderIds() {
    if (_uid == null) return const Stream.empty();

    return _db
        .collection('follows')
        .where('worshiperId', isEqualTo: _uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => d.data()['leaderId'] as String)
              .toList(),
        );
  }
}