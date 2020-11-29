import 'package:cloud_firestore/cloud_firestore.dart';

import '../data.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('students');

  Future<void> updateStudent(String name, String yearId) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'yearId': yearId,
    });
  }

  Student _studentFromSnapshot(DocumentSnapshot snapshot) {
    return Student(uid, snapshot.data()['name'], snapshot.data()['yearId']);
  }

  Stream<Student> get student {
    return userCollection.doc(uid).snapshots().map(_studentFromSnapshot);
  }
}
