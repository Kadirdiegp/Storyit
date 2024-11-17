import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static AuthService? _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoggedIn = false;

  AuthService._();

  static Future<AuthService> init() async {
    if (_instance == null) {
      _instance = AuthService._();
      _instance!._isLoggedIn = _instance!._auth.currentUser != null;
    }
    return _instance!;
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _isLoggedIn = false;
    // Optional: Clear any stored user data/tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
