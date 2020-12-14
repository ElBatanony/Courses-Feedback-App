import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/services/auth.dart';
import 'package:innopolis_feedback/services/database.dart';
import 'package:innopolis_feedback/shared/bottom_navbar.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ta_profile_page.dart';
import 'package:innopolis_feedback/ui/action_button.dart';
import 'package:innopolis_feedback/ui/app_bar.dart';
import 'package:innopolis_feedback/ui/list_item.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user;
  Student student;
  bool loading = true;
  List<TA> tas = [];

  getStudent() async {
    Student tempStudent = await DatabaseService(user.uid).student;

    List<TA> tempTas = await Future.wait(
        tempStudent.favoriteTAs.map((taId) => getTaById(taId)));

    setState(() {
      loading = false;
      tas = tempTas;
      student = tempStudent;
    });
  }

  taToWidget(TA ta) => ListItem(
        title: ta.name,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaProfilePage(ta.id, ta.name),
          ),
        ),
      );

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
            appBar: CustomAppBar(
              title: student.name,
              goBackIconVisible: true,
              onGoBack: () => Navigator.pop(context),
            ),
            body: Center(
                child: Column(
              children: [
                Text('You can visit one of your favorite TAs:'),
                Expanded(
                  child: ListView.builder(
                      itemCount: tas.length,
                      itemBuilder: (context, index) => taToWidget(tas[index])),
                ),
                ActionButton(
                    text: "Sign out?", onPressed: AuthService().signOut)
              ],
            )),
            bottomNavigationBar: BottomNavBar(
              defaultSelectedIndex: 1,
            ),
          );
  }
}
