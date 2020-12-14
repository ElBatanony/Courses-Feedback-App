import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/services/database.dart';
import 'package:innopolis_feedback/shared/bottom_navbar.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ta_profile_page.dart';
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

  getStudent() async {
    student = await DatabaseService(user.uid).student;
    setState(() {
      loading = false;
    });
  }

  taToWidget(TA ta)  => ListItem(
        title: ta.name,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaProfilePage(ta.id, ta.name))));

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
                CustomAppBar(title: student.name),
            body: Center(
                child:
                    Column(
                      children: [
                        Text('You can visit one of your favorite TAs:'),
                        ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: student.favoriteTAs.length,
                            itemBuilder: (context, index) {
                              final taId = student.favoriteTAs[index];
                              return FutureBuilder(
                                  future: getTaById(taId),
                                  builder: (context, snapshot) =>
                                      taToWidget(snapshot.data));
                            }),
                      ],
                    )
                ),
            bottomNavigationBar: BottomNavBar(),
          );
  }
}
