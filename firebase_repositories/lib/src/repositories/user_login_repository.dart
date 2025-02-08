import 'package:firebase_auth/firebase_auth.dart';

class UserLoginRepository {
  final firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> registerAccount(
      {required String userName, required String pwd}) {
    return firebaseAuth.createUserWithEmailAndPassword(
        email: userName, password: pwd);
  }

  Future<void> deleteAccount() {
    return firebaseAuth.currentUser!.delete();
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  Future<UserCredential> login(
      {required String userName, required String pwd}) {
    return firebaseAuth.signInWithEmailAndPassword(
        email: userName, password: pwd);
  }

  Future<void> logout() async {
    firebaseAuth.signOut();
  }

  Stream<User?> get userStream {
    return firebaseAuth.authStateChanges();
  }
}
