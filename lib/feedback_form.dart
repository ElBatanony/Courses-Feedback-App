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

  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    email = FirebaseAuth.instance.currentUser.email;
  }

  handleSubmitFeedback() {
    // TODO: show a confirmation message (ex: Are you sure?)
    submitFeedback(widget.taCourse, controller.text, uid, email);
    controller.text = '';
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
          RaisedButton(
            child: Text('Submit Feedback'),
            onPressed: handleSubmitFeedback,
          )
        ],
      ),
    );
  }
}
