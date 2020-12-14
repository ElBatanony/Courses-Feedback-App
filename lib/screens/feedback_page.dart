import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/shared/resend_verifivaction_mail.dart';
import 'package:innopolis_feedback/shared/styles.dart';

class FeedbackPage extends StatefulWidget {
  final StudentFeedback f;

  FeedbackPage(this.f);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<FeedbackComment> comments = [];
  String uid, email, commentText = '';
  bool emailVerified;
  User user;

  updateComments(List<FeedbackComment> c) {
    c.sort((c1,c2) => c2.date.difference(c1.date).inMilliseconds);
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
    user = FirebaseAuth.instance.currentUser;
    uid = user.uid;
    email = user.email;
    emailVerified = user.emailVerified;
    fetchComments();
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

  void submitCommentHandler() {
    submitComment(
        widget.f, FeedbackComment('', uid, email, DateTime.now(), commentText));
    commentHolder.clear();
    setState(() {
      commentText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.f.email),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Text(widget.f.message),
            emailVerified
                ? TextField(
                    controller: commentHolder,
                    maxLines: null,
                    onChanged: (val) {
                      setState(() {
                        commentText = val;
                      });
                    },
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Comment',
                      suffixIcon: commentText != ''
                          ? IconButton(
                              onPressed: submitCommentHandler,
                              icon: Icon(Icons.send),
                            )
                          : SizedBox.shrink(),
                    ),
                  )
                : ResendVerificationEmail(user),
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
