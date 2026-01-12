import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // LOGIN
  Future<User> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  // SIGNUP
  Future<User?> signup({
    required String name,
    required String email,
    required String password,
    required String role, // 'leader' | 'worshiper'
    required String faith,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) return null;

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'role': role,
      'faith': faith,
      'bio': '',
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  // FETCH ROLE
  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data() ?? const {})['role'] as String? ?? 'worshiper';
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}