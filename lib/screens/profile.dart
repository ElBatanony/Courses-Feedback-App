import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/services/database.dart';
import 'package:innopolis_feedback/shared/bottom_navbar.dart';
import 'package:innopolis_feedback/shared/loading.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user;
  Student student;
  bool loading = true;

  getStudent() async {
    student = await DatabaseService(user.uid).student;
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    getStudent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar:
                AppBar(title: Text('profile')), //here would be Irek's navbar
            body: Center(
              child: Column(
                //would be updated to Irek's list items
                children: [
                  Text(student.name),
                  Text(student
                      .yearId), //or delete or transform yeaId->Full year name
                  ...student.favoriteTAs
                      .map<Widget>((ta) => Text(ta.toString()))
                      .toList()
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              defaultSelectedIndex: 1,
            ),
          );
  }
}
