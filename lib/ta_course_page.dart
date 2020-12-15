import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:innopolis_feedback/feedback_form.dart';
import 'package:innopolis_feedback/shared/bottom_navbar.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/shared/resend_verifivaction_mail.dart';
import 'package:innopolis_feedback/ui/action_button.dart';
import 'package:innopolis_feedback/ui/app_bar.dart';

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
  User user;
  bool emailVerified;
  int selectedRating = 0;

  getData() async {
    ta = await getTaById(widget.taId);
    course = await getCourseById(widget.courseId);
    taCourse = await getTaCoursePair(ta.id, course.id);
    print(course);
    try {
      selectedRating = await getRating(taCourse.docId, uid);
    } catch (e) {}
    setState(() {});
    print(ta.name + ' - ' + course.name);
  }

  goToTaProfile() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TaProfilePage(ta.id, ta.name)));
  }

  reloadUser(User user) async {
    await user.reload();
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    reloadUser(user);
    emailVerified = user.emailVerified;
    uid = user.uid;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: CustomAppBar(
        title: widget.title,
      ),
      body: Center(
        child: taCourse == null
            ? course == null
                ? Loading()
                : Text('TA Course pair doc does not exist')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    'TA:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    ta.name,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    'Course:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    course.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    'Rating:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    '${taCourse.avgRating.toStringAsFixed(1)} / 5',
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  emailVerified
                      ? Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('Rating:'),
                                    DropdownButton<int>(
                                      value: selectedRating,
                                      onChanged: (int newValue) {
                                        setState(() {
                                          selectedRating = newValue;
                                          updateRating(
                                              taCourse.docId, uid, selectedRating);
                                        });
                                      },
                                      items:
                                          <int>[0, 1, 2, 3, 4, 5].map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value == 0
                                              ? 'No rating'
                                              : value.toString()),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            FeedbackForm(taCourse),
                          ],
                        )
                      : ResendVerificationEmail(user),
                  Expanded(child: FeedbackDisplay(taCourse)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    child: ActionButton(
                      text: 'TA profile',
                      onPressed: goToTaProfile,
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        defaultSelectedIndex: 0,
      ),
    );
  }
}
