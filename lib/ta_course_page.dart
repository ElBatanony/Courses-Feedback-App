import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:innopolis_feedback/feedback_form.dart';

import 'data.dart';
import 'ta_profile_page.dart';

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
  String uid;

  int selectedRating = 0;

  getData() async {
    ta = await getTaById(widget.taId);
    course = await getCourseById(widget.courseId);
    taCourse = await getTaCoursePair(ta.id, course.id);
    selectedRating = await getRating(taCourse.docId, uid);
    setState(() {});
    print(ta.name + ' - ' + course.name);
  }

  goToTaProfile() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TaProfilePage(ta.id, ta.name)));
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    getData();
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
                  RaisedButton(
                      child: Text('Go to TA profile'),
                      onPressed: goToTaProfile),
                  Text('TA: ' + ta.name),
                  Text('Course: ' + course.name),
                  // Text('Rating: ' + taCourse.rating.toString())
                  // TODO: wait for auto average rating (backend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Rating:'),
                      DropdownButton<int>(
                        value: selectedRating,
                        onChanged: (int newValue) {
                          setState(() {
                            selectedRating = newValue;
                            updateRating(taCourse.docId, uid, selectedRating);
                          });
                        },
                        items: <int>[0, 1, 2, 3, 4, 5].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                                value == 0 ? 'No rating' : value.toString()),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  FeedbackForm(taCourse),
                  Expanded(child: FeedbackDisplay(taCourse))
                ],
              ),
      ),
    );
  }
}
