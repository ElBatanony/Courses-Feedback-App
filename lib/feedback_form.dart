import 'package:flutter/material.dart';
import 'package:innopolis_feedback/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innopolis_feedback/services/auth.dart';

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
        widget.taCourse.courseId, controller.text, uid, email, null);
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
  final AuthService _auth = AuthService();
  bool isAdmin = false;

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

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Student>(
      future: getStudentById(_auth.getCurrentUserId()),
      builder: (futureContext, snapshot) {
        if (snapshot.hasData) {
          isAdmin = snapshot.data.isAdmin;
        }
        return Container(
          child: ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              var f = feedbackList[index];
              return ListTile(
                title: Text(f.email),
                subtitle: Text(f.message),
                trailing: Builder(
                  builder: (context) {
                    if (isAdmin || _auth.getCurrentUserId() == f.uid) {
                      return PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          onSelected: (value) async {
                            switch (value) {
                              case "remove":
                                var itemType = "Feedback";
                                var representation;
                                if (f.message.length < 10) {
                                  representation =
                                      f.message.substring(0, f.message.length);
                                } else {
                                  representation =
                                      f.message.substring(0, 10) + "...";
                                }
                                try {
                                  await deleteFeedback(f.id);
                                  showSuccessSnackBar(context,
                                      "$itemType '$representation' successfully deleted!");
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
                                break;
                              case "removeAllFromUser":
                                var itemType = "Feedback";
                                Student student;
                                try {
                                  student = await getStudentById(f.uid);
                                  await deleteFeedbackByStudentTaCourse(
                                      f.uid, f.courseId, f.taId);
                                  showSuccessSnackBar(context,
                                      "All $itemType from ${student.name} successfully deleted!");
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
                                break;
                              case "removeUser":
                                var itemType = "User";
                                Student student;
                                try {
                                  student = await getStudentById(f.uid);
                                  if (f.uid == _auth.getCurrentUserId()) {
                                    throw Exception(
                                        "You can't delete yourself");
                                  }
                                  await deleteStudent(f.uid);

                                  showSuccessSnackBar(context,
                                      "$itemType '${student.name}' successfully deleted!");
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
                                break;
                            }
                          },
                          itemBuilder: itemBuilder);
                    }
                    return Container(width: 0, height: 0);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
