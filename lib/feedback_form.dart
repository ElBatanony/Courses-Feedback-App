import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'data.dart';

class FeedbackForm extends StatefulWidget {
  final TaCourse taCourse;

  FeedbackForm(this.taCourse);

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  TextEditingController controller = new TextEditingController();
  String uid, email;
  bool isAnonymous = false;

  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    email = FirebaseAuth.instance.currentUser.email;
  }

  handleSubmitFeedback() {
    // TODO: show a confirmation message (ex: Are you sure?)
    StudentFeedback f = new StudentFeedback(widget.taCourse.taId,
        widget.taCourse.courseId, controller.text, uid, email);
    submitFeedback(f, isAnonymous);
    controller.text = '';
    setState(() {
      isAnonymous = false;
    });
    // TODO: display a notification (snackbar) to show that feedback was sent
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: 'Your feedback message', labelText: 'Feedback'),
          ),
          SwitchListTile(
            title: Text('Anonymous feedback'),
            value: isAnonymous,
            onChanged: (value) {
              setState(() {
                isAnonymous = value;
              });
            },
          ),
          RaisedButton(
            child: Text('Submit Feedback'),
            onPressed: handleSubmitFeedback,
          )
        ],
      ),
    );
  }
}

class FeedbackDisplay extends StatefulWidget {
  final TaCourse taCourse;

  FeedbackDisplay(this.taCourse);

  @override
  _FeedbackDisplayState createState() => _FeedbackDisplayState();
}

class _FeedbackDisplayState extends State<FeedbackDisplay> {
  List<StudentFeedback> feedbackList = [];

  updateFeedback(List<StudentFeedback> f) {
    setState(() {
      feedbackList = f;
    });
  }

  fetchFeedback() {
    getFeedback(widget.taCourse).listen((f) {
      updateFeedback(f);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: feedbackList.length,
        itemBuilder: (context, index) {
          var f = feedbackList[index];
          // TODO: add option to delete one's own feedback
          return ListTile(
            title: Text(f.email),
            subtitle: Text(f.message),
          );
        },
      ),
    );
  }
}
