import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/shared/resend_verifivaction_mail.dart';
import 'package:innopolis_feedback/shared/styles.dart';
import 'package:innopolis_feedback/ui/app_bar.dart';

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
    c.sort((c1, c2) => c2.date.difference(c1.date).inMilliseconds);
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
      '${date.hour}:${date.minute}\n${date.day}.${date.month}.${date.year}';

  Widget commentToWidget(FeedbackComment c) => ListTile(
        title: Text(c.email),
        subtitle: Text(c.text),
        trailing: Text(
          prettyDate(c.date),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
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
      appBar: CustomAppBar(
        title: widget.f.email,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(widget.f.message),
              ),
            ),
          ),
          emailVerified
              ? Container(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    controller: commentHolder,
                    maxLines: null,
                    onChanged: (val) {
                      setState(() {
                        commentText = val;
                      });
                    },
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Leave a comment ...',
                      suffixIcon: commentText != ''
                          ? IconButton(
                              onPressed: submitCommentHandler,
                              icon: Icon(Icons.send),
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                )
              : ResendVerificationEmail(user),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              'Comments:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) =>
                    commentToWidget(comments[index])),
          ),
        ],
      ),
    );
  }
}
