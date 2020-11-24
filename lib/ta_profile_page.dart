import 'package:flutter/material.dart';

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

  List<Course> courses = [];

  getTA() async {
    ta = await getTaById(widget.taId);
    setState(() {});
    getCourses();
  }

  getCourses() async {
    courses = await getCoursesByTA(ta);
    setState(() {});
  }

  selectCourse(Course course) async {
    String title = ta.name + ' - ' + course.name;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaCoursePage(title, ta.id, course.id)));
  }

  @override
  void initState() {
    getTA();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TA - ' + widget.taName),
      ),
      body: Center(
        child: ta != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ID: ' + ta.id),
                  Text('Name: ' + ta.name),
                  Text('Rating: unimplemented/5'),
                  displayCourses(courses, selectCourse),
                  displayIssues(ta)
                ],
              )
            : Text('Loading ...'),
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
