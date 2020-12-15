import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/services/database.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ui/app_bar.dart';

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

  @override
  void initState() {
    getTA();
    uid = FirebaseAuth.instance.currentUser.uid;
    db = DatabaseService(uid);
    getStudent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'TA - ' + widget.taName,
      ),
      body: Center(
        child: ta != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text('ID: ' + ta.id),
                          Text('Name: ' + ta.name),
                          Text('Rating: unimplemented/5'),
                        ],
                      ),
                      IconButton(
                          icon: Icon(isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border),
                          onPressed: () async {
                            isFavorite
                                ? student.favoriteTAs.remove(ta.id)
                                : student.favoriteTAs.add(ta.id);
                            await db.updateStudent(
                                favoriteTAs: student.favoriteTAs);
                            setState(() {
                              isFavorite = student.isFavoriteTa(ta.id);
                            });
                          })
                    ],
                  ),
                  displayCourses(courses, selectCourse),
                  displayIssues(ta)
                ],
              )
            : Loading(),
      ),
    );
  }
}

Widget displayCourses(List<Course> courses, Function selectCourse) {
  return Column(children: [
    Text('Courses:'),
    ...courses
        .map((course) => ListTile(
              title: Text(course.name),
              subtitle: Text(course.yearId),
              onTap: () => selectCourse(course),
            ))
        .toList()
  ]);
}

Widget displayIssues(TA ta) {
  return Text('Issues are yet to be implemented');
}
