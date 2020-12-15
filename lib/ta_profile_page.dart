import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/services/database.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ui/action_button.dart';
import 'package:innopolis_feedback/ui/app_bar.dart';
import 'package:innopolis_feedback/ui/sub_title.dart';

import 'data.dart';
import 'ta_course_page.dart';

class TaProfilePage extends StatefulWidget {
  final String taId;
  final String taName;

  TaProfilePage(this.taId, this.taName);

  @override
  _TaProfilePageState createState() => _TaProfilePageState();
}

class _TaProfilePageState extends State<TaProfilePage> {
  TA ta;
  String uid;
  Student student;
  DatabaseService db;
  bool isFavorite = false;

  List<Course> courses = [];

  getTA() async {
    ta = await getTaById(widget.taId);
    setState(() {});
    getCourses();
  }

  getStudent() async {
    student = await db.student;
    setState(() {
      isFavorite = student.isFavoriteTa(ta.id);
    });
  }

  getCourses() async {
    courses = await getCoursesByTA(ta);
    setState(() {});
  }

  selectCourse(Course course) async {
    String title = ta.name;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaCoursePage(title, ta.id, course.id)));
  }

  init() async {
    await getTA();
    uid = FirebaseAuth.instance.currentUser.uid;
    db = DatabaseService(uid);
    await getStudent();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.taName,
      ),
      body: Center(
        child: ta != null
            ? Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: displayCourses(courses, selectCourse),
                    ),
                    ActionButton(
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border),
                      text:
                          '${isFavorite ? 'Remove from' : 'Add to'} favourites',
                      onPressed: () async {
                        isFavorite
                            ? student.favoriteTAs.remove(ta.id)
                            : student.favoriteTAs.add(ta.id);
                        await db.updateStudent(
                            favoriteTAs: student.favoriteTAs);
                        setState(() {
                          isFavorite = student.isFavoriteTa(ta.id);
                        });
                      },
                    ),
                  ],
                ),
              )
            : Loading(),
      ),
    );
  }
}

Widget displayCourses(List<Course> courses, Function selectCourse) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SubTitle('Courses'),
      ...courses
          .map((course) => ListTile(
                title: Text(course.name),
                subtitle: Text(course.yearId.toUpperCase()),
                onTap: () => selectCourse(course),
              ))
          .toList()
    ],
  );
}
