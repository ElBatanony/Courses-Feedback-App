import 'package:firebase_auth/firebase_auth.dart';
import 'package:innopolis_feedback/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> get user {
    return _auth.authStateChanges();
  }

  String getCurrentUserId() {
    return _auth.currentUser != null ? _auth.currentUser.uid : null;
  }

  Future signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future signUp(String email, String password, String name) async {
    try {
      UserCredential response = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await DatabaseService(response.user.uid).updateStudent(name: name);
      return response.user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
