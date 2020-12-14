import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innopolis_feedback/screens/home/home.dart';
import 'package:innopolis_feedback/services/auth.dart';
import 'package:innopolis_feedback/screens/feedback_page.dart';

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

  handleSubmitFeedback() async {
    // TODO: show a confirmation message (ex: Are you sure?)
    StudentFeedback f = new StudentFeedback('', widget.taCourse.taId,
        widget.taCourse.courseId, controller.text, uid, email, [], []);
    await submitFeedback(f, isAnonymous);
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
  final AuthService _auth = AuthService();
  bool isAdmin = false;
  String uid, email;

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

  List<PopupMenuEntry<dynamic>> itemBuilder(BuildContext context) {
    List<PopupMenuEntry<dynamic>> result = [
      PopupMenuItem(
          value: "remove",
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.delete),
              ),
              Text('Delete feedback')
            ],
          ))
    ];

    if (isAdmin) {
      result.add(PopupMenuItem(
          value: "removeAllFromUser",
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.delete_sweep),
              ),
              Text('Delete all from user')
            ],
          )));
      result.add(PopupMenuItem(
          value: "removeUser",
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.person_remove),
              ),
              Text('Delete user')
            ],
          )));
    }

    return result;
  }

  handleUpvote(StudentFeedback f) {
    // toggle the upvote state
    if (f.upvotes.contains(email))
      f.upvotes.remove(email);
    else
      f.upvotes.add(email);
    // make sure that there is no downvote at the same time
    f.downvotes.remove(email);
    return updateVotes(f);
  }

  handleDownvote(StudentFeedback f) {
    // toggle the downvote state
    if (f.downvotes.contains(email))
      f.downvotes.remove(email);
    else
      f.downvotes.add(email);
    // make sure that there is no upvote at the same time
    f.upvotes.remove(email);
    return updateVotes(f);
  }

  Future<bool> areYouSure(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  handleFeedbackLongPress(BuildContext context, StudentFeedback f) async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete feedback'),
              onTap: () async {
                var itemType = "Feedback";
                var representation;
                if (f.message.length < 10) {
                  representation = f.message.substring(0, f.message.length);
                } else {
                  representation = f.message.substring(0, 10) + "...";
                }
                try {
                  if (await areYouSure("Delete feedback",
                      "Are you sure you want to delete this feedback?")) {
                    await deleteFeedback(f);
                    showSuccessSnackBar(context,
                        "$itemType '$representation' successfully deleted!");
                  }
                } catch (e, p) {
                  print(e.toString() + ' ' + p.toString());
                  if (e.toString().contains("] ")) {
                    showErrorSnackBar(
                        context,
                        "Unable to delete $itemType '$representation'",
                        e.toString().split("] ")[1]);
                  } else {
                    showErrorSnackBar(
                        context,
                        "Unable to delete $itemType '$representation'",
                        e.toString());
                  }
                }
                await fetchFeedback();
                Navigator.pop(bottomSheetContext);
              },
            ),
            (isAdmin)
                ? ListTile(
                    leading: Icon(Icons.delete_sweep),
                    title: Text('Delete all from user'),
                    onTap: () async {
                      var itemType = "Feedback";
                      Student student;
                      try {
                        student = await getStudentById(f.uid);
                        if (await areYouSure("Delete all feedback from user",
                            "Are you sure you want to delete all feedback left here from this user?")) {
                          await deleteFeedbackByStudentInTaCourse(
                              f.uid, f.courseId, f.taId);
                          showSuccessSnackBar(context,
                              "All $itemType from ${student.name} successfully deleted!");
                        }
                      } catch (e, p) {
                        print(e.toString() + ' ' + p.toString());
                        if (e.toString().contains("] ")) {
                          showErrorSnackBar(
                              context,
                              "Unable to delete $itemType from ${student.name ?? "User"}.",
                              e.toString().split("] ")[1]);
                        } else {
                          showErrorSnackBar(
                              context,
                              "Unable to delete $itemType from ${student.name ?? "User"}.",
                              e.toString());
                        }
                      }
                      await fetchFeedback();
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            (isAdmin)
                ? ListTile(
                    leading: Icon(Icons.person_remove),
                    title: Text('Delete user'),
                    onTap: () async {
                      var itemType = "User";
                      Student student;
                      try {
                        student = await getStudentById(f.uid);
                        if (f.uid == _auth.getCurrentUserId()) {
                          throw Exception("You can't delete yourself");
                        }
                        if (await areYouSure("Delete user",
                            "Are you sure you want to delete this user and all related feedback?")) {
                          await deleteStudent(f.uid);
                          showSuccessSnackBar(context,
                              "$itemType '${student.name}' successfully deleted!");
                        }
                      } catch (e, p) {
                        print(e.toString() + ' ' + p.toString());
                        if (e.toString().contains("] ")) {
                          showErrorSnackBar(
                              context,
                              "Unable to delete $itemType '${student.name ?? "username"}'.",
                              e.toString().split("] ")[1]);
                        } else {
                          showErrorSnackBar(
                              context,
                              "Unable to delete $itemType '${student.name ?? "username"}'.",
                              e.toString());
                        }
                      }
                      await fetchFeedback();
                      Navigator.pop(context);
                    },
                  )
                : Container(),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    email = FirebaseAuth.instance.currentUser.email;
    fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<Student>(
          future: getStudentById(uid),
          builder: (futureContext, snapshot) {
            if (snapshot.hasData) {
              isAdmin = snapshot.data.isAdmin();
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              showErrorSnackBar(context, "Failed fetching user role", "");
            }

            return ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (listContext, index) {
                var f = feedbackList[index];
                bool upvoted = f.upvotes.contains(email);
                bool downvoted = f.downvotes.contains(email);
                // TODO: display a negative or toxic warning depending on the sentiment of the feedback
                return ListTile(
                  title: Text(f.email),
                  subtitle: Text(f.message),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FeedbackPage(f))),
                  onLongPress: (f.uid == uid || isAdmin)
                      ? () => handleFeedbackLongPress(context, f)
                      : null,
                  leading: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: upvoted ? Colors.deepPurple[100] : null),
                    constraints: BoxConstraints(maxWidth: 72),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(f.upvotes.length.toString()),
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () => handleUpvote(f),
                          )
                        ]),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: downvoted ? Colors.red[200] : null,
                    ),
                    constraints: BoxConstraints(maxWidth: 72),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(f.downvotes.length.toString()),
                        IconButton(
                          icon: Icon(Icons.arrow_downward),
                          onPressed: () => handleDownvote(f),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
