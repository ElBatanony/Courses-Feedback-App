import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/shared/styles.dart';

class FeedbackPage extends StatefulWidget {
  final StudentFeedback f;

  FeedbackPage(this.f);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<FeedbackComment> comments = [];
  String uid, email;

  updateComments(List<FeedbackComment> c) {
    setState(() {
      comments = c;
    });
  }

  fetchComments() {
    getComments(widget.f.feedbackId).listen((c) {
      updateComments(c);
    });
  }

  @override
  void initState() {
    fetchComments();
    uid = FirebaseAuth.instance.currentUser.uid;
    email = FirebaseAuth.instance.currentUser.email;
    super.initState();
  }


  String prettyDate(DateTime date) =>
      '${date.hour}:${date.minute} ${date.day}.${date.month}.${date.year}';

  Widget commentToWidget(FeedbackComment c) => ListTile(
        title: Text(c.email),
        subtitle: Text(c.text),
        trailing: Text(prettyDate(c.date)),
      );

  final commentHolder = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.f.email), centerTitle: true,),
        body: Column(
          children: [
            Text(widget.f.message),
            TextField(
              controller: commentHolder,
              onSubmitted: (String comment) {
                submitComment(widget.f,
                    FeedbackComment('', uid, email, DateTime.now(), comment));
                commentHolder.clear();
              },
              decoration: textInputDecoration.copyWith(hintText: 'Comment'),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) =>
                      commentToWidget(comments[index])),
            ),
          ],
        ));
  }
}
