import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  

  User? get currentUserState => _firebaseAuth.currentUser;

  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  Future<void> loginUserWithEmailAndPassword(
      {required  email, required password}) async {
    
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    
  }

  Future<void> signUpWithEmailAndPassword(
      {required  email, required password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
