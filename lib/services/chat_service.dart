import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Deterministic chat id between two users
  String chatIdFor(String userA, String userB) {
    if (userA.compareTo(userB) < 0) {
      return '${userA}_$userB';
    } else {
      return '${userB}_$userA';
    }
  }

  /// Send a message to [otherUserId]
  Future<void> sendMessage({
    required String otherUserId,
    required String text,
  }) async {
    if (_uid == null || text.trim().isEmpty) return;

    final chatId = chatIdFor(_uid!, otherUserId);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    await _db.runTransaction((tx) async {
      final chatSnap = await tx.get(chatRef);
      if (!chatSnap.exists) {
        tx.set(chatRef, {
          'participants': [_uid, otherUserId],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      tx.set(msgRef, {
        'senderId': _uid,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Stream messages for chat with [otherUserId], newest last
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(
      String otherUserId) {
    if (_uid == null) {
      return const Stream.empty();
    }
    final chatId = chatIdFor(_uid!, otherUserId);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// All chats that current user is in, for leader's "Messages" list
  Stream<QuerySnapshot<Map<String, dynamic>>> myChats() {
    if (_uid == null) {
      return const Stream.empty();
    }
    return _db
        .collection('chats')
        .where('participants', arrayContains: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}