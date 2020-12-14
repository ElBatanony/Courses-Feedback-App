import 'package:firebase_auth/firebase_auth.dart';
import 'package:innopolis_feedback/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> get user {
    return _auth.authStateChanges();
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

  Future signUp(
      String email, String password, String name, String yearId) async {
    try {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((response) async {
           await DatabaseService(response.user.uid)
            .updateStudent(name: name, yearId: yearId);
           return response.user;
      });
    } catch (error) {
      print(error.toString());
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
