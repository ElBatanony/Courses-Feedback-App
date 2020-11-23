import 'package:flutter/material.dart';

import 'data.dart';

class TaCoursePage extends StatefulWidget {
  final String title, taId, courseId;

  TaCoursePage(this.title, this.taId, this.courseId);

  @override
  _TaCoursePageState createState() => _TaCoursePageState();
}

class _TaCoursePageState extends State<TaCoursePage> {
  TA ta;
  Course course;
  TaCourse taCourse;

  getData() async {
    ta = await getTaById(widget.taId);
    course = await getCourseById(widget.courseId);
    taCourse = await getTaCoursePair(ta.id + '_' + course.id);
    setState(() {});
    print(ta.name + ' - ' + course.name);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: taCourse == null
            ? course == null
                ? Text('Loading ...')
                : Text('TA Course pair doc does not exist')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TA: ' + ta.name),
                  Text('Course: ' + course.name),
                  Text('Rating: ' + taCourse.rating.toString())
                ],
              ),
      ),
    );
  }
}
