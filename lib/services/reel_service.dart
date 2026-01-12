import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReelService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// DEMO upload: skip Firebase Storage, use a public sample video URL
  Future<void> uploadReel({
    required File videoFile,
    required String caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final uid = user.uid;
    final reelId = DateTime.now().millisecondsSinceEpoch.toString();

    // Public sample mp4; works without Storage.
    const fakeVideoUrl =
        'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4';

    await _db.collection('reels').doc(reelId).set({
      'videoUrl': fakeVideoUrl,
      'caption': caption,
      'leaderId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream reels ordered newest first
  Stream<QuerySnapshot<Map<String, dynamic>>> reelsStream() {
    return _db
        .collection('reels')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}