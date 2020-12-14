import 'package:cloud_firestore/cloud_firestore.dart';

import '../data.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('students');

  Future<void> updateStudent(
      {String name, String yearId, List<String> favoriteTAs}) async {
    return await userCollection.doc(uid).set({
      if (name != null) 'name': name,
      if (yearId != null) 'yearId': yearId,
      if (favoriteTAs != null) 'favoriteTAs': favoriteTAs
    }, SetOptions(merge: true));
  }

  Student _studentFromSnapshot(DocumentSnapshot snapshot) {
    return Student(
        uid,
        snapshot.data()['name'] ?? 'No name',
        snapshot.data()['yearId'] ?? 'No year',
        snapshot.data()['favoriteTAs'] != null
            ? snapshot
                .data()['favoriteTAs']
                .map<String>((id) => id.toString())
                .toList()
            : []);
  }

  Future<Student> get student =>
      userCollection.doc(uid).get().then(_studentFromSnapshot);
}
